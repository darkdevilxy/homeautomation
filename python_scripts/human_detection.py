import cv2
import time
import light_control

def main():
    # Initialize webcam
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print("Error: Could not access the webcam.")
        return
    
    print("Press 'q' to quit the application.")

    # Set up initial frame for comparison
    _, frame1 = cap.read()
    _, frame2 = cap.read()

    light_on = False  # Simulate the lightbulb status

    while True:
        # Convert frames to grayscale and blur for noise reduction
        gray1 = cv2.cvtColor(frame1, cv2.COLOR_BGR2GRAY)
        gray2 = cv2.cvtColor(frame2, cv2.COLOR_BGR2GRAY)
        gray1 = cv2.GaussianBlur(gray1, (21, 21), 0)
        gray2 = cv2.GaussianBlur(gray2, (21, 21), 0)

        # Compute the absolute difference between frames
        diff = cv2.absdiff(gray1, gray2)
        _, thresh = cv2.threshold(diff, 25, 255, cv2.THRESH_BINARY)

        # Find contours of the motion
        contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        motion_detected = False

        for contour in contours:
            if cv2.contourArea(contour) > 500:  # Adjust sensitivity here
                motion_detected = True
                break

        # Simulate light response
        if motion_detected and not light_on:
            light_control.light_control('On')
        elif not motion_detected and light_on:
            light_on = False
            turn_off_light()

        # Show the video feed
        cv2.imshow("Live Video Feed", frame2)
        cv2.imshow("Motion Detection", thresh)

        # Update frames for the next iteration
        frame1 = frame2
        _, frame2 = cap.read()

        # Quit on 'q' key press
        if cv2.waitKey(10) & 0xFF == ord('q'):
            break

    # Release resources
    cap.release()python_scripts/human_detection.py
    cv2.destroyAllWindows()

def turn_on_light():
    # Placeholder for light control logic
    print("Light ON")

def turn_off_light():
    # Placeholder for light control logic
    print("Light OFF")

if __name__ == "__main__":
    main()
