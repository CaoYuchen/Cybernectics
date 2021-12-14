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
      //println("x: " + point.x + " y: " + point.y);
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
    pWidth  * (projectorMatrix[0]*kinectPoint.x + projectorMatrix[1]*kinectPoint.y + projectorMatrix[2]*kinectPoint.z + projectorMatrix[3]) / denom, 
    pHeight * (projectorMatrix[4]*kinectPoint.x + projectorMatrix[5]*kinectPoint.y + projectorMatrix[6]*kinectPoint.z + projectorMatrix[7]) / denom);
}

void mirror(){
// mirroring
  for (int h = 0; h < kinect2.depthHeight; h++)
  {
    for (int r = 0; r < kinect2.depthWidth / 2; r++)
    {
      PVector temp = depthMap[h*kinect2.depthWidth + r];
      depthMap[h*kinect2.depthWidth + r] = depthMap[h*kinect2.depthWidth + (kinect2.depthWidth - r - 1)];
      depthMap[h*kinect2.depthWidth + (kinect2.depthWidth - r - 1)] = temp;
    }
  }
  
  // mirroring
  for (int h = 0; h < stream.height; h++)
  {
    for (int r = 0; r < stream.width / 2; r++)
    {
      int temp2 = stream.get(r, h);   //h*src.width + r);
      stream.set(r, h, stream.get(stream.width - r - 1, h));
      stream.set(stream.width - r - 1, h, temp2);
    }
  }
  
  // mirroring
  for (int h = 0; h < registered.height; h++)
  {
    for (int r = 0; r < registered.width / 2; r++)
    {
      int temp3 = registered.get(r, h);   //h*src.width + r);
      registered.set(r, h, registered.get(registered.width - r - 1, h));
      registered.set(registered.width - r - 1, h, temp3);
    }
  }
}
