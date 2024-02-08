import java.io.*;
import java.awt.Robot;
import java.awt.event.KeyEvent;
import java.awt.datatransfer.*;
import processing.core.*;

Textfield textField, nameField;
Slider slider;
Button startButton, saveButton;

// Variables for customization
color backgroundColor = color(15);  //give 3 values if you want RGB
color textColor = color(230, 190, 0);
color textBoxBackgroundColor = color(50); //give 3 values if you want RGB
color nameColor = color(25, 140, 255);
color nameBoxBackgroundColor = color(50); //give 3 values if you want RGB
color sliderColor = color(0, 128, 255);
color startButtonColor = color(40, 40, 40);
color startButtonTextColor = color(0, 230, 77);
color saveButtonColor = color(40, 40, 40);
color saveButtonTextColor = color(0, 230, 77);
color labelsTextColor = color(230, 0, 230);

int textSendDelay = 25;  //milliseconds delay for sending characters
String clipboardContent = "";
boolean isMonitoring = false;
int delayInSeconds = 1;
int lastCheckedTime = 0;

int messageDisplayTime = 1000; // Display the message for 3 seconds
int messageDisplayStartTime = 0;
boolean showMessage = false;
String displayedMessage = ""; // Store the message to be displayed

void setup() {
  size(500, 150);
  textAlign(CENTER, CENTER); // Set text alignment to center
  textField = new Textfield(20, 20, 460, 20);
  slider = new Slider(150, 60, 200, 20, 1, 61);
  startButton = new Button(20, 100, 100, 40, "Start");
  textField.setText("Coordinates will appear here");
  nameField = new Textfield(130, 100, 240, 20);
  nameField.setText("Location Name");
  saveButton = new Button(380, 100, 100, 40, "Save");
  surface.setAlwaysOnTop(true);
  startButton.addListener(new ButtonListener() {
    void onClick() {
      toggleMonitoring();
    }
  }
  );
  saveButton.addListener(new ButtonListener() {
    void onClick() {
      saveData();
    }
  }
  );
}

void draw() {
  background(backgroundColor);
  delayInSeconds = int(slider.getValue()) * 1000;
  textField.draw(textColor, textBoxBackgroundColor); // Pass the text box background color variable
  
  // Draw "delay" label on the left side of the slider
  fill(labelsTextColor);
  textAlign(RIGHT, CENTER);
  text("Delay", slider.x - 20, slider.y + slider.h / 2);
  
  // Draw the value of the delay on the right side of the slider
  textAlign(LEFT, CENTER);
  text(int(slider.getValue()) + " seconds", slider.x + slider.w + 20, slider.y + slider.h / 2);

  slider.draw(sliderColor);
  startButton.draw(startButtonColor, startButtonTextColor);
  nameField.draw(nameColor, nameBoxBackgroundColor);
  saveButton.draw(saveButtonColor, saveButtonTextColor);
  if (isMonitoring && millis() - lastCheckedTime >= delayInSeconds) {
    sendKeyString("/showlocation");
    String newClipboardContent = getClipboardContent();
    if (!newClipboardContent.equals(clipboardContent)) {
      clipboardContent = newClipboardContent;
      textField.setText(clipboardContent);
    }
    lastCheckedTime = millis();
  }

  if (showMessage) {
    fill(0, 255, 0); // Green color for success message
    text(displayedMessage, width / 2, height - 20);
    if (millis() - messageDisplayStartTime >= messageDisplayTime) {
      showMessage = false;
    }
  }
}


void mousePressed() {
  startButton.mousePressed();
  saveButton.mousePressed();

  // Check if the mouse is pressed inside the nameField
  if (mouseX > nameField.x && mouseX < nameField.x + nameField.w && mouseY > nameField.y && mouseY < nameField.y + nameField.h) {
    nameField.selected = true; // Set the nameField as selected
  } else {
    nameField.selected = false; // Set the nameField as not selected
  }
}

void keyPressed() {
  if (nameField.selected) {
    if (keyCode == BACKSPACE && nameField.text.length() > 0) {
      nameField.text = nameField.text.substring(0, nameField.text.length() - 1);
    } else if ((keyCode >= 32 && keyCode <= 126) && nameField.text.length() < 30) {
      nameField.text += key;
    }
  }
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

void saveData() {
  String name = nameField.text;
  String coordinates = textField.text;

  // Get the directory of the sketch
  String sketchDirectory = sketchPath("");

  // Define the file path
  String filePath = sketchDirectory + File.separator + "SavedLocations.txt";

  // Create or append to the text file
  try {
    File file = new File(filePath);
    if (!file.exists()) {
      file.createNewFile();
      println("New file created: " + filePath);
    }

    FileWriter fileWriter = new FileWriter(filePath, true);
    PrintWriter writer = new PrintWriter(fileWriter);

    // Write data to the file
    writer.println(name + ": " + coordinates);
    writer.close();
    println("Data saved successfully.");

    // Display a message on the screen indicating successful save
    showMessage("Data saved successfully");
  } catch (IOException e) {
    println("Error saving data: " + e);
    // Display a message on the screen indicating error in saving
    showMessage("Error saving data: " + e.getMessage());
  }
}

void showMessage(String message) {
  messageDisplayStartTime = millis();
  showMessage = true;
  displayedMessage = message; // Store the message to be displayed
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
  boolean selected = false; // Indicates if the textfield is selected for input

  Textfield(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void draw(color textColor, color textBoxBackgroundColor) {
    if (selected) {
      fill(255); // Change text color to white when selected
    } else {
      fill(textBoxBackgroundColor); // Set the text box background color
    }
    rect(x, y, w, h);
    fill(textColor);
    textAlign(LEFT, CENTER);
    text(text, x + 5, y + h / 2);
  }


  void setText(String newText) {
    text = newText;
  }
}
