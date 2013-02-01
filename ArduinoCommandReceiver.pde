#define BACKWARD LOW
#define FORWARD HIGH
#define MOVEFORWARD 1
#define MOVEBACKWARD 2
#define TURNLEFT 3
#define TURNRIGHT 4

char labViewData[100]={};
int labViewDataLength=0,commaCount=0;
int rtdp = 12, ltdp = 13, rtsp = 3, ltsp = 11; // rtdp=RrightTireDirectionPin, ltsp=LeftTireSpeedPin (infer the others)
int lastAction=0;
String left_s="",right_s="",forward_s="",backward_s="",speed_s="";
int left,right,forward,backward,speed;


void setup(){
  // set pin modes
  pinMode(rtdp,OUTPUT);
  pinMode(ltdp,OUTPUT);
  pinMode(rtsp,OUTPUT);
  pinMode(ltsp,OUTPUT);
  stop();
  Serial3.begin(9600);
 // Serial.begin(9600);
}

void loop(){
  
  if(Serial3.available()){
    // LabVIEW program sent command
   labViewDataLength=Serial3.readBytesUntil(';',labViewData,50); // read the command LabVIEW sent
   for(int i=0;i<labViewDataLength;i++){
     // separate data
    if(labViewData[i]==','){
     // increase comma count
     commaCount++;
    }
    if(commaCount==0 && labViewData[i]!=','){
     // read left 
     left_s=left_s+labViewData[i];
    }else if(commaCount==1 && labViewData[i]!=','){
      // read right
      right_s=right_s+labViewData[i];
    }else if(commaCount==2 && labViewData[i]!=','){
      // read forward
      forward_s=forward_s+labViewData[i];
    }else if(commaCount==3 && labViewData[i]!=','){
      // read backward
      backward_s=backward_s+labViewData[i];
    }else if(commaCount==4 && labViewData[i]!=','){
     // read speed 
     speed_s=speed_s+labViewData[i];
    }
   }
  
   // change data from strings to integers
   left=(int)left_s.toFloat();
   right=(int)right_s.toFloat();
   forward=(int)forward_s.toFloat();
   backward=(int)backward_s.toFloat();
   speed=(int)speed_s.toFloat();
 /*  Serial.print("Left: ");
   Serial.println(left,DEC);
   Serial.print("Right: ");
   Serial.println(right,DEC);
   Serial.print("Forward: ");
   Serial.println(forward,DEC);
   Serial.print("Backward: ");
   Serial.println(backward,DEC);
   Serial.print("Speed: ");
   Serial.println(speed,DEC);*/
 
  }
  // control wheels
  control(left,right,forward,backward,speed);
  // reset variables
  commaCount=0;
  left_s="";
  right_s="";
  forward_s="";
  backward_s="";
  speed_s="";

}

void control(int leftParam, int rightParam, int forwardParam, int backwardParam, int speedParam){
   if(leftParam){
     turnLeft(speedParam);
   }else if(rightParam){
     turnRight(speedParam);
   }else if(forwardParam){
     moveForward(speedParam);
   }else if(backwardParam){
     moveBackward(speedParam);
   }else{
     
      switch(lastAction){
      case MOVEFORWARD:
        analogWrite(ltsp,speedParam);
        analogWrite(rtsp,speedParam);
       break;
      case MOVEBACKWARD:
        analogWrite(ltsp,speedParam);
        analogWrite(rtsp,speedParam);
       break;
      case TURNLEFT:
        analogWrite(rtsp,0);
        analogWrite(ltsp,speedParam);
       break;
      case TURNRIGHT:
        analogWrite(ltsp,0);
        analogWrite(rtsp,speedParam);
       break;
      default:
      // do nothing
      //stop();
       break; 
     }
   }
}

void turnRight(int speedParam){
  digitalWrite(rtdp,BACKWARD);
  analogWrite(ltsp,0);
  analogWrite(rtsp,speedParam);
  lastAction=TURNRIGHT;
}

void turnLeft(int speedParam){
  digitalWrite(ltdp,BACKWARD);
  analogWrite(rtsp,0);
  analogWrite(ltsp,speedParam);
  lastAction=TURNLEFT;
  
}

void moveForward(int speedParam){
  digitalWrite(ltdp,FORWARD);
  digitalWrite(rtdp,FORWARD);
  analogWrite(ltsp,speedParam);
  analogWrite(rtsp,speedParam);
  lastAction=MOVEFORWARD;
}

void moveBackward(int speedParam){
  digitalWrite(ltdp,BACKWARD);
  digitalWrite(rtdp,BACKWARD);
  analogWrite(ltsp,speedParam);
  analogWrite(rtsp,speedParam);
  lastAction=MOVEBACKWARD;
}

void stop(){
  analogWrite(ltsp,0);
  analogWrite(rtsp,0);
}

