int oldVal = LOW;
void setup() {
  pinMode(13, OUTPUT);
  pinMode(5, INPUT);
  Serial.begin(9600);
}

void loop() {
  int val = digitalRead(5);
  if(val == HIGH && oldVal == LOW){
    digitalWrite(13, HIGH);
    Serial.println("1");
    delay(200);
  }
  else{
    digitalWrite(13, LOW);
  }

  oldVal = val;
}
