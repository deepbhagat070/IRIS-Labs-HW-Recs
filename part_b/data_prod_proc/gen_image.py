import random

filename = "image.hex"
width = 32
height = 32

# Optional: Set seed so you get the SAME random pattern every time you run this script.
# Remove this line if you want a different pattern every time.
random.seed(99) 

with open(filename, "w") as f:
    for row in range(height):
        for col in range(width):
            # Generate random value between 0 (0x00) and 255 (0xFF)
            val = random.randint(0, 255)
            f.write(f"{val:02x}\n")

print(f"Successfully generated {filename} with 1024 random pixels.")