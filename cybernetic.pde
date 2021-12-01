import org.openkinect.processing.*; //<>// //<>// //<>// //<>// //<>//
import gab.opencv.*;
import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;

// depends on projector's resolution
int pWidth = 1920;
int pHeight = 1080; 

//kinect related
String calibFile ="/Users/joshuarain/Documents/Processing/libraries/KinectProjectorToolkit/examples/CALIBRATION/data/calibration.txt";
Kinect2 kinect2;
OpenCV opencv;
PVector [] depthMap;
int projectorSize;
PImage stream;
float[] projectorMatrix;
ArrayList<Contour> contours;
ArrayList<PVector> center;

//vector field related
Vector[][] vectors;
Actor[] a;
int numPoints = pWidth * pHeight/100;
int speed = 1;
float vecImpact = 0.01;
int ageCounter = 0;
int defaultAge = 200;

void setup() {
  size(800, 800);
  surface.setSize(pWidth, pHeight);
  strokeWeight(0.1);
  stroke(255);
  noiseSeed(int(random(0, 1000)));
  noiseDetail(3);    
  vectors = new Vector[pWidth][pHeight];
  for (int i = 0; i < pWidth; i++) {
    for (int j = 0; j < pHeight; j++) {
      vectors[i][j] = new Vector(i, j);
    }
  }
  int numPts1D = floor(sqrt(numPoints));
  a = new Actor[numPoints];
  for (int i = 0; i < numPoints; i++) {
    float x = (i % numPts1D) * (pWidth/numPts1D);
    float y = (int(i / numPts1D)) * (pHeight/numPts1D);
    a[i] = new Actor(vectors, x, y);
  }
  background(255);

  //kinect setting
  kinect2 = new Kinect2(this);
  kinect2.initDepth(); 
  //kinect2.initVideo();
  //kinect2.initRegistered();
  //kinect2.initIR();
  kinect2.initDevice();
  projectorSize = kinect2.depthWidth*kinect2.depthHeight;
  depthMap = new PVector[projectorSize];
  opencv = new OpenCV(this, kinect2.depthWidth, kinect2.depthHeight);
  loadCalibration(calibFile);
  center = new ArrayList<PVector>();
}

void draw() {

  //get image from Kinect
  depthMap = depthMapRealWorld();
  stream = kinect2.getDepthImage();

  opencv.loadImage(stream);
  opencv.erode();
  opencv.gray();
  opencv.threshold(50);
  //image(opencv.getOutput(),800,0);

  // optical flow
  //translate(810,0);
  //opencv.calculateOpticalFlow();
  //opencv.drawOpticalFlow();
  //for (int i =0; i< projectorSize; i++) {
  //  int x = i%kinect2.depthWidth;
  //  int y = i/kinect2.depthWidth;
  //  PVector flow = opencv.getFlowAt(x, y);
  //  //println(flow);

  //  PVector ProjectorCoord = convertKinectToProjector(depthMap[i]);
  //  x = round(ProjectorCoord.x);
  //  y = round(ProjectorCoord.y);
  //  // change the vector field
  //  float strength = sqrt(flow.x*flow.x+flow.y*flow.y);
  //  if (strength >= 20) {
  //    if (x>=0 && x<kinect2.depthWidth && y>=0 && y<kinect2.depthHeight) {
  //      vectors[x][y].x += flow.x * 10;
  //      vectors[x][y].y += flow.y * 10;
  //    }
  //  }
  //}
  //translate(-810,0);
  //println(vectors[400][400].x,vectors[400][400].y);


  // contour
  contours = opencv.findContours();

  noFill();
  strokeWeight(3);
  image(opencv.getOutput(), 800, 0);
  // get max and min of area
  float max_area = contours.get(0).getPolygonApproximation().area();
  float min_area = contours.get(0).getPolygonApproximation().area();
  for (Contour contour : contours) {
    max_area = max(contour.getPolygonApproximation().area(), max_area);
    min_area = min(contour.getPolygonApproximation().area(), min_area);
  }
  // print/show
  translate(810, 0);
  for (Contour contour : contours) {

    stroke(0, 255, 0);
    //contour.draw();
    stroke(255, 0, 0);
    beginShape();
    if (contour.getPolygonApproximation().area()>max_area*0.75) {
      for (PVector point : contour.getPolygonApproximation().getPoints()) {
        vertex(point.x, point.y);
      }
    }
    endShape();
  }
  
  //println("number of contours: " + contours.size());
  // find center
  stroke(0, 255, 255);
  strokeWeight(5);
  for (Contour contour : contours) {
    PVector average = new PVector(0, 0);
    PVector averageDraw = new PVector(0, 0);
    if (contour.getPolygonApproximation().area()>max_area*0.75) {
      for (PVector point : contour.getPoints()) {
        PVector p = new PVector(point.x, point.y);
        PVector ProjectorCoord = convertKinectToProjector(p);
        average.x += ProjectorCoord.x;
        average.y += ProjectorCoord.y;
        
        averageDraw.x += p.x;
        averageDraw.y += p.y;
      }
      average.x = round(average.x/(contour.getPoints().size()));
      average.y = round(average.y/(contour.getPoints().size()));
      center.add(average);
      
      averageDraw.x = round(averageDraw.x/(contour.getPoints().size()));
      averageDraw.y = round(averageDraw.y/(contour.getPoints().size()));
      point(averageDraw.y, averageDraw.x);
      //println("x: "+average.x+"y: "+average.y);
    }
  }
  stroke(255);
  strokeWeight(0.1);
  translate(-810, 0);
  //projector points
  int ii = 0;
  for (Contour contour : contours) {
    if (contour.getPolygonApproximation().area()>max_area*0.75) {
      for (PVector point : contour.getPoints()) {
        PVector p = new PVector(point.x, point.y);
        PVector ProjectorCoord = convertKinectToProjector(p);
        int x = round(ProjectorCoord.x);
        int y = round(ProjectorCoord.y);
        //println("x: " + x + " y: " + y);
        if (x>=0 && x<pHeight && y>=0 && y<pWidth) {
          //println("find the target");
          float sum = sqrt(pow(x-center.get(ii).x,2)+pow(y-center.get(ii).y,2));
          vectors[y][x].x += (x-center.get(ii).x)/sum;
          vectors[y][x].y += (y-center.get(ii).y)/sum;
        }
      }
      ii++;
    }
  }
  //println("i: "+ii);

  //comment out to see vector lines
  //for (int i = 0; i < width; i+= 20) {
  //  for (int j = 0; j < height; j+=20) {
  //    line(i,j,(i+vectors[i][j].x*10),(j+vectors[i][j].y*10));
  //  }
  //}
  // update the points
  ageCounter++;
  for (int i = 0; i < numPoints; i++) {
    a[i].update();
  }
  //println("xpos: "+a[1000].xpos+"; ypos: "+ a[1000].ypos);
  println("v.x: "+a[1000].vectors[30][30].x+"; v.y: "+ a[1000].vectors[30][30].y);
}


// all functions below used to generate depthMapRealWorld point cloud
PVector[] depthMapRealWorld()
{
  int[] depth = kinect2.getRawDepth();
  int skip = 1;
  for (int y = 0; y < kinect2.depthHeight; y+=skip) {
    for (int x = 0; x < kinect2.depthWidth; x+=skip) {
      int offset = x + y * kinect2.depthWidth;
      //calculate the x, y, z camera position based on the depth information
      PVector point = depthToPointCloudPos(x, y, depth[offset]);
      depthMap[kinect2.depthWidth * y + x] = point;
    }
  }
  return depthMap;
}

//calculte the xyz camera position based on the depth data
PVector depthToPointCloudPos(int x, int y, float depthValue) {
  PVector point = new PVector();
  point.z = (depthValue);// / (1.0f); // Convert from mm to meters
  point.x = ((x - CameraParams.cx) * point.z / CameraParams.fx);
  point.y = ((y - CameraParams.cy) * point.z / CameraParams.fy);
  return point;
}

//camera information based on the Kinect v2 hardware
static class CameraParams {
  static float cx = 254.878f;
  static float cy = 205.395f;
  static float fx = 365.456f;
  static float fy = 365.456f;
  static float k1 = 0.0905474;
  static float k2 = -0.26819;
  static float k3 = 0.0950862;
  static float p1 = 0.0;
  static float p2 = 0.0;
}

// calibrated matrix
void loadCalibration(String filename) {
  String[] s = loadStrings(dataPath(filename));
  projectorMatrix = new float[s.length];
  for (int i=0; i<s.length; i++)
    projectorMatrix[i] = Float.parseFloat(s[i]);
}

// world 3D points to 2D projector plane
PVector convertKinectToProjector(PVector kinectPoint) {
  float denom = projectorMatrix[8]*kinectPoint.x + projectorMatrix[9]*kinectPoint.y + projectorMatrix[10]*kinectPoint.z + 1.0f;
  return new PVector(
    kinect2.depthWidth  * (projectorMatrix[0]*kinectPoint.x + projectorMatrix[1]*kinectPoint.y + projectorMatrix[2]*kinectPoint.z + projectorMatrix[3]) / denom, 
    kinect2.depthHeight * (projectorMatrix[4]*kinectPoint.x + projectorMatrix[5]*kinectPoint.y + projectorMatrix[6]*kinectPoint.z + projectorMatrix[7]) / denom);
}
