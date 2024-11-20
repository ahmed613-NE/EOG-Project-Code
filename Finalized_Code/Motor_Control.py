# Backyard Brains Sep. 2019
# Made for python 3
# First install serial library
# Install numpy, pyserial, matplotlib
# pip3 install pyserial
#
# Code will read, parse and display data from BackyardBrains' serial devices
#
# Written by Stanislav Mircic
# stanislav@backyardbrains.com

import threading
import serial as serial
import time
import numpy as np
import matplotlib.pyplot as plt



global connected
connected = False
#change name of the port here
port = 'COM4'
#port = '/dev/cu.usbmodem1411101'
baud = 230400
global input_buffer
global sample_buffer
global cBufTail
cBufTail = 0
input_buffer = []
sample_rate = 10000
display_size = 30000 #3 seconds
sample_buffer = np.linspace(0,0,display_size)
serial_port = serial.Serial(port, baud, timeout=0)
serial_port2 = serial.Serial('COM3',baud,timeout=1)
serial_port3 = serial.Serial('COM9',baud,timeout=2)
# Define motor control functions
def rotate_clockwise():
    try:
        serial_port2.write("CW\n".encode())
        serial_port2.flush()  # Ensure buffer is flushed
        print("Command sent: Rotate clockwise")
    except serial.SerialException as e:
        print("Error writing to COM3:", e)

def rotate_counterclockwise():
    try:
        serial_port2.write("CCW\n".encode())
        serial_port2.flush()  # Ensure buffer is flushed
        print("Command sent: Rotate counterclockwise")
    except serial.SerialException as e:
        print("Error writing to COM3:", e)

def rotate_angle(peak):
    """
    Calculate the motor rotation angle based on a polynomial equation of the peak value
    and send it to the Arduino to rotate the motor.
    
    Parameters:
    peak (float): The peak value from the buffer used to calculate the motor rotation angle.
    """
    # Polynomial equation for motor rotation angle
    motor_angle =  (peak)*0.22+89#Horizontal
    #motor_angle = (peak)*0.24+93.6#vertical 
    # Ensure motor angle is within the motor's valid rotation range if necessary (e.g., 0 to 180)
    motor_angle = int(max(min(motor_angle, 180), 0))
    
    # Send the motor angle to the Arduino
    command = f"{motor_angle}\n"  # Convert to a string with newline character
    serial_port2.write(command.encode())  # Send command over serial
    serial_port2.flush()
    serial_port3.write(command.encode())
    serial_port3.flush()
    serial_port.flush()
    print(f"Command sent: Rotate to {motor_angle} degrees")


def checkIfNextByteExist():
        global cBufTail
        global input_buffer
        tempTail = cBufTail + 1
        
        if tempTail==len(input_buffer): 
            return False
        return True
    

def checkIfHaveWholeFrame():
        global cBufTail
        global input_buffer
        tempTail = cBufTail + 1
        while tempTail!=len(input_buffer): 
            nextByte  = input_buffer[tempTail] & 0xFF
            if nextByte > 127:
                return True
            tempTail = tempTail +1
        return False;
    
def areWeAtTheEndOfFrame():
        global cBufTail
        global input_buffer
        tempTail = cBufTail + 1
        nextByte  = input_buffer[tempTail] & 0xFF
        if nextByte > 127:
            return True
        return False

def numberOfChannels():
    return 1

def handle_data(data):
    global input_buffer
    global cBufTail
    global sample_buffer    
    if len(data)>0:

        cBufTail = 0
        haveData = True
        weAlreadyProcessedBeginingOfTheFrame = False
        numberOfParsedChannels = 0
        
        while haveData:
            MSB  = input_buffer[cBufTail] & 0xFF
            
            if(MSB > 127):
                weAlreadyProcessedBeginingOfTheFrame = False
                numberOfParsedChannels = 0
                
                if checkIfHaveWholeFrame():
                    
                    while True:
                        
                        MSB  = input_buffer[cBufTail] & 0xFF
                        if(weAlreadyProcessedBeginingOfTheFrame and (MSB>127)):
                            #we have begining of the frame inside frame
                            #something is wrong
                            break #continue as if we have new frame
            
                        MSB  = input_buffer[cBufTail] & 0x7F
                        weAlreadyProcessedBeginingOfTheFrame = True
                        cBufTail = cBufTail +1
                        LSB  = input_buffer[cBufTail] & 0xFF

                        if LSB>127:
                            break #continue as if we have new frame

                        LSB  = input_buffer[cBufTail] & 0x7F
                        MSB = MSB<<7
                        writeInteger = LSB | MSB
                        numberOfParsedChannels = numberOfParsedChannels+1
                        if numberOfParsedChannels>numberOfChannels():
            
                            #we have more data in frame than we need
                            #something is wrong with this frame
                            break #continue as if we have new frame
            

                        sample_buffer = np.append(sample_buffer,writeInteger-512)
                        

                        if areWeAtTheEndOfFrame():
                            break
                        else:
                            cBufTail = cBufTail +1
                else:
                    haveData = False
                    break
            if(not haveData):
                break
            cBufTail = cBufTail +1
            if cBufTail==len(input_buffer):
                haveData = False
                break


def read_from_port(ser):
    global connected
    global input_buffer
    while not connected:
        #serin = ser.read()
        connected = True

        while True:
           
           reading = ser.read(1024)
           if(len(reading)>0):
                reading = list(reading)
#here we overwrite if we left some parts of the frame from previous processing 
#should be changed             
                input_buffer = reading.copy()
                #print("len(reading)",len(reading))
                handle_data(reading)
           
           time.sleep(0.001)

thread = threading.Thread(target=read_from_port, args=(serial_port,))
thread.start()
xi = np.linspace(-display_size/sample_rate, 0, num=display_size)


window_size_ms = 300  # Adjustable window size
window_size_samples = int((window_size_ms / 1000) * sample_rate)
threshold = 25
cooldown_period_ms = 100
last_peak_time = 0

while True:
    plt.ion()
    plt.show(block=False)
    
    if len(sample_buffer) > 0:
        yi = sample_buffer[-window_size_samples:].copy()  # Use refined window size
        
        # Find positive and negative peaks
        positive_peak = max((val for val in yi if val > 0), default=None)
        negative_peak = min((val for val in yi if val < 0), default=None)
        
        # Determine peak with the largest absolute value
        if positive_peak is not None or negative_peak is not None:
            peak = positive_peak if abs(positive_peak or 0) >= abs(negative_peak or 0) else negative_peak
            peak = int(peak)
           
            # Filter by threshold and cooldown period
            current_time = time.time() * 1000
            if peak is not None and abs(peak) > threshold and (current_time - last_peak_time > cooldown_period_ms):
                rotate_angle(peak)
                last_peak_time = current_time
                print(f"Peak processed: {peak}")
            else:
                print(f"Ignored peak: {peak}")
                
    # Plot data
    plt.clf()
    plt.ylim(-550, 550)
    plt.plot(xi[-window_size_samples:], yi, linewidth=1, color='royalblue')
    plt.pause(0.001)
    time.sleep(0.08)
