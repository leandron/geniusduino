//
// =============
//  GeniusDuino
// =============
// # Leandro Nunes : leandron85[at]gmail[dot]com
//  # Website: http://github.com/leandron/geniusduino
//  # Blog: http://leandron.wordpress.com
//
// Instructions to assembly:
// - put buttons in digital pins, 4, 5, 6 and 7
// - put leds in digital pins 8, 9, 10 and 11
//

const int ST_BEGIN = 0;
const int ST_SHOW = 1;
const int ST_WAIT_INPUT = 2;
const int ST_INPUT_ERROR = 3;
const int ST_INPUT_OK = 4;

int error_pin = 13;
int ok_pin = 12;
int input_button[] = {4,5,6,7};
int output_led[] = {8,9,10,11};

int combination_button[100];
int combination_led[100];
int comb_counter = 0;

int game_state;
int user_input_counter;
int pressed_button;
bool lock_buttons = false;
bool button_pressed_now = false;
bool logging = true;

void setup() {
  // Set the button input mode
  for (int i=0; i < 4; i++) {
    pinMode(input_button[i], INPUT);
    pinMode(output_led[i], OUTPUT);
  }
  
  pinMode(error_pin, OUTPUT);
  pinMode(ok_pin, OUTPUT);
  randomSeed(analogRead(0));
  
  if (logging) {
    Serial.begin(9600);
  }
  change_game_state(ST_BEGIN);
}

//implements the states of the device
void loop() {
  switch(game_state) {
    case ST_BEGIN:
      begin_action();
      break;
    case ST_SHOW:
      show_and_generate_action();
      clean_inputs();
      change_game_state(ST_WAIT_INPUT);
      break;
    case ST_WAIT_INPUT:
      read_buttons_action();
      break;
    case ST_INPUT_ERROR:
      input_error_action();
      break;
    case ST_INPUT_OK:
      input_ok_action();
      break;
  }
}

void input_error_action() {
  digitalWrite(error_pin, HIGH);
}

void input_ok_action() {
  digitalWrite(ok_pin, HIGH);
  delay(1000);
  digitalWrite(ok_pin, LOW);
  change_game_state(ST_SHOW);
}

void change_game_state(int new_state) {
  if (logging) {
    Serial.print("state has changed:");
    Serial.println(new_state);
  }
  
  game_state = new_state;
}

void clean_inputs() {
  user_input_counter = 0;
}

void read_buttons_action() {
  button_pressed_now = false;
  
  for (int i=0; i < 4; i++) {
    if ((digitalRead(input_button[i]) == HIGH) && !lock_buttons) {
      lock_buttons = true;
      button_pressed_now = true;
      pressed_button = input_button[i];
      Serial.print("button pressed:");
      Serial.println(pressed_button);
    }
  }
  
  if (!button_pressed_now) {
    lock_buttons = false;
  }
  
  if (button_pressed_now && lock_buttons) {
    verify_user_input(pressed_button);
  }
}

void verify_user_input(int pressed) {
  Serial.print("user input counter:");
  Serial.println(user_input_counter);

  if (pressed != combination_button[user_input_counter]) {
    Serial.print(pressed);
    Serial.print("!=");
    Serial.println(combination_button[user_input_counter]);
    change_game_state(ST_INPUT_ERROR);
  }
 
  user_input_counter++;
  
  if (user_input_counter == comb_counter) {
    user_input_counter = 0;
    change_game_state(ST_INPUT_OK);
  }
 
} 

void show_and_generate_action() {
  int temp_int = random(4);
  combination_led[comb_counter] = output_led[temp_int];
  combination_button[comb_counter] = input_button[temp_int];
  if (logging) {
    Serial.print("next button:");
    Serial.println(combination_button[comb_counter]);
  }
  comb_counter++;

  for (int i=0; i < comb_counter; i++) {
    Serial.print("comb:");
    Serial.println(combination_button[i]);
    Serial.print("comb led:");
    Serial.println(combination_led[i]);
    Serial.print("comb counter:");
    Serial.println(comb_counter);
    blink_led(combination_led[i]);
  }

}

void begin_action() {
  init_lights();
  change_game_state(ST_SHOW);
}

void blink_led(int pin) {
  digitalWrite(pin, HIGH);
  delay(500);
  digitalWrite(pin, LOW);  
}

void init_lights() {
  for (int i; i < sizeof(output_led); i++) {
    blink_led(output_led[i]);
  }
}
