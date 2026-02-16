Part A
Q 1.) Explain why synchronizing each bit of an encoded multibit control signal independently can lead to incorrect decoding in the receiving clock domain.
Ans: Synchronizing each bit of a multibit bus in this case a multibit control signal independently is fundamental CDC design error due Skee in signal
•	Signal Skew: In physical circuit individual bits of a multibit bus travel along different wire paths. Variations in wire length, capacitance and resistance these bits will arrive at the destination flip-flops at different time.
•	Sampling Mismatch: When the destination clock samples these bits, the skew may cause some bits to be captured in the current clock cycle while other bits are delayed enough to be captured in the next cycle this causes of providing the wrong result or output.
•	Invalid States: This creates a temporary "glitches" or invalid state where the receiving logic sees a mix of old and new values. As shown in question waveform if a control signal changes from 000 to 111 and the least significant bit arrives slightly faster than the others the synchronizer might momentarily output 001 instead of 111 for one clock cycle which causes this glitches and error.
•	Functional Failure: If this bus feeds into combinational logic like the decoder in question this invalid intermediate value 001 can trigger an incorrect output giving aen [1] instead of aen [7] leading to system failure.
Q2.) Using the timing diagram, describe how skew between b [1] and b [0] causes adec [2:0] to momentarily take an invalid intermediate value.
Ans: Based on the provided timing diagram the error occurs during the transition of the input bus from 0 to 7 (111).
•	The Skew: The diagram shows that the signal b [0] arrives at the destination slightly earlier than b [1] and b [2] due to propagation delay.
•	The Race Condition: At the rising edge of the destination clock (Aclk) b[0] has already stabilized to logic High 1 and is successfully captured or received. However, b [1] and b [2] arrive slightly late and they miss the setup window of the flip-flops and are captured or stay as logic Low 0.
•	The Glitch: Consequently, for one clock cycle, the synchronized output bus (aq1) reads as 001 for one clock cycle which is incorrect and instead of showing 111 at the output.
•	The Result: The decoder interprets this temporary 001 value for one clock cycle as valid input and incorrectly asserts aen[1] creating a spurious control pulse instead of desire output of aen[7].
 

 
This small delay b[1] and b[2] creates a delay in further circuit and creating glitches or invalid outputs.
 Q3.) Identify the fundamental CDC design mistake illustrated in this figure.
Ans: The use of separate 2-flip-flop synchronizers to transfer a multibit signal across clock domains is the basic design error shown in the figure. The application of this synchronization technique to a multibit bus is flawed because individual bits arrive at the destination flip-flops at slightly different time due to delays and due to variations in wire length and routing delays known as skew even though it is standard for single-bit signals. Because of this timing variation, the destination clock is unable to ensure that every bit is captured at once, which frequently leads to a mix of ‘old’ and ‘new’ bit values being sampled in the same cycle. This breaks the time coherence of the data and creates some intermediate states or glitches which may lead to the incorrect logic operations in further application of that data.
Q4.) Propose three different design techniques that can be used to safely transfer this control information across clock domains without generating spurious decoded outputs.
Ans: 
1.	Gray Code Encoding:
Converting the binary signal into Gray code before transmitting it across the clock boundary. In Gray code only single bit changes at any transition. Because only one bit changes at a time, there is no race between multiple bits. Skew cannot create an invalid between state the destination clock will sample either the stable "old" value or the stable "new" value but never a glitch or incorrect state.
2.	Handshake Protocol:
This method uses a stable data bus and a separate control signal. The source holds the data stable on the bus and then asserts a single bit "Request" signal. The destination synchronizes only the "Request" bit. Once the synchronized Request is detected the destination captures the data and sends back an "Acknowledge" signal. The data bus itself is never sampled while it is changing. It is guaranteed to be stable before the receiver reads it eliminating any risk of skew errors.
3.	Asynchronous FIFO (First-In-First-Out):
Decouple the domains using a dual-clock FIFO buffer. The source clock is used to write data into a shared memory, and the destination clock is used to read it out. The internal synchronization of the read and write pointers is usually achieved through the use of Gray code. This method maintains the order of arrival and guarantees data integrity. Because only the pointers not the data itself ever directly cross the clock boundary it is the most reliable method for moving streams of data or send the control information in this case.





Design Overview 
My design uses a "Streaming Line Buffer" architecture. Instead of waiting for the entire image to load which can take a long time and lot of memory this design processes the image pixel by-pixel as it flows in from the camera or image file. To perform the time Convolution which needs data from the pixels above in mode 2 I used two Line Buffers. These act like a short-term memory, holding exactly two rows of the image so the processor can see and read  the neighbours of the current pixel. 
Design Evolution & Learning Process
My final architecture was chosen after analysing different approaches:
•	Initial approach in my first try I tried to process pixels directly without buffering. I missed the alternate inputs which made it impossible and it was wrong approach as there is difference in clk speed of processor and producer to perform spatial filtering like edge detection and inverting of pixels.
•	My solution is based on the learning from Boot Camp reference material, I implemented the Line Buffer approach that help me to avoid the skipping of data 
•	I observed a slight delay (latency) of one clock cycle between the Producer and the Processor. Reason is this delay is intentional and necessary. It comes from the Pipeline Registers and the Valid/Ready Handshake the benefit is it adds a tiny delay it ensures the data is stable and synchronized before the math calculations happen. This prevents "glitches" in the image and metastability.


Advantage is speed. In a software approach a processor has to read each pixel one by one and do the math and save it takes many clock cycles for every single dot. This design does all the filiping, multiplication and addition in parallel using a pipeline. This means it produces one finished pixel every single clock cycle making it fast enough for real time processing.
Finally, the design is safer because of the synchronization logic I learned from the boot camp materials. I noticed a small delay of one clock cycle between the producer and the processor, but this is actually a good thing. This delay comes from the handshake signals that ensure data is stable before it gets processed. This prevents glitches and metastability.


   
