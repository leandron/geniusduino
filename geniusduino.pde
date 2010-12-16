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

int combination[100];
int comb_counter = 0;

int game_state;
int user_input_counter;
int pressed_button;
bool lock_buttons = false;
bool button_pressed_now = false;

void setup() {
  // Set the button input mode
  for (int i=0; i < 4; i++) {
    pinMode(input_button[i], INPUT);
    pinMode(output_led[i], OUTPUT);
  }
  
  pinMode(error_pin, OUTPUT);
  pinMode(ok_pin, OUTPUT);
  randomSeed(analogRead(0));
  
  Serial.begin(9600);
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
    all_lights_on(200);
    delay(200);
    all_lights_on(200);
    change_game_state(ST_BEGIN);
}

void input_ok_action() {
  digitalWrite(ok_pin, HIGH);
  delay(1000);
  digitalWrite(ok_pin, LOW);
  change_game_state(ST_SHOW);
}

void change_game_state(int new_state) { 
  game_state = new_state;
}

void clean_inputs() {
  user_input_counter = 0;
}

void read_buttons_action() {
  button_pressed_now = false;
  
  for (int i=0; i < 4; i++) {
    if (digitalRead(input_button[i]) == HIGH) {
      button_pressed_now = true;
      pressed_button = i;
      break;
    }
  }
  
  if (!button_pressed_now) {
    lock_buttons = false;
  }
  
  if (button_pressed_now && !lock_buttons) {
    Serial.print("pressed button: ");
    Serial.println(pressed_button);
    verify_user_input(pressed_button);
    lock_buttons = true;
  }
}

void verify_user_input(int pressed) {
  if (pressed != combination[user_input_counter]) {
    change_game_state(ST_INPUT_ERROR);
    return;
  }
 
  user_input_counter++;
  
  if (user_input_counter == comb_counter) {
    user_input_counter = 0;
    all_lights_on(1000);
    change_game_state(ST_INPUT_OK);
  } 
} 

void show_and_generate_action() {
  combination[comb_counter] = random(1000) % 4;
  comb_counter++;

  Serial.print("memory: ");
  for (int i=0; i < comb_counter; i++) {
    Serial.print(combination[i]);
    Serial.print(" ");
    blink_led(output_led[combination[i]], 500);
    delay(50);
  }
  Serial.println(" ");

}

void begin_action() {
  init_lights();
  comb_counter = 0;
  change_game_state(ST_SHOW);
}

void blink_led(int pin) {
  blink_led(pin, 500);
}

void blink_led(int pin, int time) {
  digitalWrite(pin, HIGH);
  delay(time);
  digitalWrite(pin, LOW);  
}

void init_lights() {
  for (int i; i < sizeof(output_led); i++) {
    blink_led(output_led[i], 300);
  }
}

void all_lights_on(int time) {
  for (int i; i < sizeof(output_led); i++) {
    digitalWrite(output_led[i], HIGH);
  }
  delay(time);
  for (int i; i < sizeof(output_led); i++) {
    digitalWrite(output_led[i], LOW);
  }
}
