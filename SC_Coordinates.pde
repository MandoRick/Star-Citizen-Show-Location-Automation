//you can open and run this scrip with Processing Java.  You can also export it as an exe in Processing.  Visit processing.org
import java.awt.Robot;
import java.awt.event.KeyEvent;
import java.awt.datatransfer.*;
import processing.core.*;

Textfield textField;
Slider slider;
Button startButton;

// Variables for customization
color backgroundColor = color(15);  //give 3 values if you want RGB
color textColor = color(230, 0, 230);
color sliderColor = color(0, 128, 255);
color buttonColor = color(40, 40, 40);
color buttonTextColor = color(0, 230, 77);
color textBoxBackgroundColor = color(50); //give 3 values if you want RGB

int textSendDelay = 25;  //milliseconds delay for sending characters
String clipboardContent = "";
boolean isMonitoring = false;
int delayInSeconds = 1;
int lastCheckedTime = 0;


void setup() {
  size(500, 150);
  textField = new Textfield(20, 20, 460, 20);
  slider = new Slider(20, 60, 200, 20, 1, 10);
  startButton = new Button(20, 100, 100, 40, "Start");
  textField.setText("Coordinates will appear here");
  surface.setAlwaysOnTop(true);
  startButton.addListener(new ButtonListener() {
    void onClick() {
      toggleMonitoring();
    }
  }
  );
}

void draw() {
  background(backgroundColor);
  delayInSeconds = int(slider.getValue()) * 1000;
  textField.draw(textColor, textBoxBackgroundColor); // Pass the text box background color variable
  slider.draw(sliderColor);
  startButton.draw(buttonColor, buttonTextColor);
  if (isMonitoring && millis() - lastCheckedTime >= delayInSeconds) {
    sendKeyString("/showlocation");
    String newClipboardContent = getClipboardContent();
    if (!newClipboardContent.equals(clipboardContent)) {
      clipboardContent = newClipboardContent;
      textField.setText(clipboardContent);
    }
    lastCheckedTime = millis();
  }
}

void mousePressed() {
  startButton.mousePressed();
}

void mouseDragged() {
  slider.mouseDragged();
}

void toggleMonitoring() {
  isMonitoring = !isMonitoring;
  if (isMonitoring) {
    startButton.label = "Stop";
    lastCheckedTime = millis();
  } else {
    startButton.label = "Start";
  }
}

void sendKeyString(String keyString) {
  try {
    Robot robot = new Robot();
    robot.delay(textSendDelay);
    robot.keyPress(KeyEvent.VK_ENTER);
    robot.delay(textSendDelay);
    robot.keyRelease(KeyEvent.VK_ENTER);
    for (char c : keyString.toCharArray()) {
      robot.keyPress(KeyEvent.getExtendedKeyCodeForChar(c));
      robot.delay(textSendDelay);
      robot.keyRelease(KeyEvent.getExtendedKeyCodeForChar(c));
      robot.delay(textSendDelay);
    }
    robot.delay(textSendDelay);
    robot.keyPress(KeyEvent.VK_ENTER);
    robot.delay(textSendDelay);
    robot.keyRelease(KeyEvent.VK_ENTER);
  }
  catch (Exception e) {
    e.printStackTrace();
  }
  delay(250);
}

String getClipboardContent() {
  Clipboard clipboard = java.awt.Toolkit.getDefaultToolkit().getSystemClipboard();
  Transferable contents = clipboard.getContents(null);
  if (contents != null && contents.isDataFlavorSupported(DataFlavor.stringFlavor)) {
    try {
      return contents.getTransferData(DataFlavor.stringFlavor).toString();
    }
    catch (Exception e) {
      e.printStackTrace();
    }
  }
  return "";
}
interface ButtonListener {
  void onClick();
}

// Button class
class Button {
  float x, y, w, h;
  String label;
  ButtonListener listener;

  Button(float x, float y, float w, float h, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
  }

  void draw(color buttonColor, color buttonTextColor) {
    fill(buttonColor);
    rect(x, y, w, h);
    fill(buttonTextColor);
    textAlign(CENTER, CENTER);
    text(label, x + w / 2, y + h / 2);
  }

  void addListener(ButtonListener listener) {
    this.listener = listener;
  }

  void mousePressed() {
    if (mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h) {
      if (listener != null) {
        listener.onClick();
      }
    }
  }
}

// Slider class
class Slider {
  float x, y, w, h;
  float minVal, maxVal;
  float value;

  Slider(float x, float y, float w, float h, float minVal, float maxVal) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.minVal = minVal;
    this.maxVal = maxVal;
    this.value = minVal;
  }

  void draw(color sliderColor) {
    fill(sliderColor);
    rect(x, y, w, h);
    float mappedX = map(value, minVal, maxVal, x, x + w);
    fill(0);
    rect(mappedX - 5, y, 10, h);
  }

  float getValue() {
    return value;
  }

  void mouseDragged() {
    if (mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h) {
      value = map(mouseX, x, x + w, minVal, maxVal);
      value = constrain(value, minVal, maxVal);
    }
  }
}

// Textfield class
class Textfield {
  float x, y, w, h;
  String text = "";

  Textfield(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void draw(color textColor, color textBoxBackgroundColor) {
    fill(textBoxBackgroundColor); // Set the text box background color
    rect(x, y, w, h);
    fill(textColor);
    textAlign(LEFT, CENTER);
    text(text, x + 5, y + h / 2);
  }

  void setText(String newText) {
    text = newText;
  }
}
