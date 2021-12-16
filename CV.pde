void opticalflow(){
  // optical flow
  translate(810,0);
  opencv.calculateOpticalFlow();
  opencv.drawOpticalFlow();
  for (int i =0; i< projectorSize; i++) {
    int x = i%kinect2.depthWidth;
    int y = i/kinect2.depthWidth;
    PVector flow = opencv.getFlowAt(x, y);
    //println(flow);

    PVector ProjectorCoord = convertKinectToProjector(depthMap[i]);
    x = round(ProjectorCoord.x);
    y = round(ProjectorCoord.y);
    // change the vector field
    float strength = sqrt(flow.x*flow.x+flow.y*flow.y);
    if (strength >= 20) {
      if (x>=0 && x<kinect2.depthWidth && y>=0 && y<kinect2.depthHeight) {
        vectors[x][y].x += flow.x * 10;
        vectors[x][y].y += flow.y * 10;
      }
    }
  }
  translate(-810,0);
  //println(vectors[400][400].x,vectors[400][400].y);
}

void contour(){
  // contour
  contours = opencv.findContours();

  noFill();
  strokeWeight(3);
  //image(opencv.getOutput(), 800, 0);
  // get max and min of area
  float max_area = 0;
  float min_area = Float.MAX_VALUE;
  for (Contour contour : contours) {
    max_area = max(contour.getPolygonApproximation().area(), max_area);
    min_area = min(contour.getPolygonApproximation().area(), min_area);
  }
  // print/show
  //translate(810, 0);
  for (Contour contour : contours) {
    //stroke(0, 255, 0);
    //contour.draw();
    stroke(255, 0, 0);
    beginShape();
    if (contour.area()>max_area*contourT && contour.area()<kinect2.depthWidth*kinect2.depthHeight*sigma && contour.getPoints().size()>contourSize) {
      for (PVector point : contour.getPoints()) {
        vertex(point.x/kinect2.depthWidth*pWidth, point.y/kinect2.depthHeight*pHeight);
        //vertex(point.x, point.y);
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
    //PVector averageDraw = new PVector(0, 0);
    if (contour.getPolygonApproximation().area()>max_area*contourT && contour.getPolygonApproximation().area()<kinect2.depthWidth*kinect2.depthHeight*sigma && contour.getPoints().size()>contourSize) {
      Rectangle bbox = contour.getBoundingBox();
      average.x = bbox.x+0.5*bbox.width;
      average.y = bbox.y+0.5*bbox.height;
      average.x = round(average.x/kinect2.depthWidth*pWidth);
      average.y = round(average.y/kinect2.depthHeight*pHeight);
      center.add(average);
      //point(average.x, average.y);
      //for (PVector point : contour.getPolygonApproximation().getPoints()) {
      //  //PVector p = new PVector(point.x, point.y);
      //  //println("points: "+p);
      //  PVector p = depthMap[(int)point.x+(int)point.y*kinect2.depthWidth];
      //  PVector ProjectorCoord = convertKinectToProjector(p);
      //  average.x += ProjectorCoord.x;
      //  average.y += ProjectorCoord.y;
      //  averageDraw.x += p.x;
      //  averageDraw.y += p.y;
      //}
      //average.x = round(average.x/(contour.getPoints().size()));
      //average.y = round(average.y/(contour.getPoints().size()));
      ////center.add(average);
      
      //averageDraw.x = round(averageDraw.x/(contour.getPoints().size()));
      //averageDraw.y = round(averageDraw.y/(contour.getPoints().size()));
      //center.add(averageDraw);
      //point(averageDraw.y, averageDraw.x);
      //println("x: "+average.x+"y: "+average.y);
      //println("x: "+average.x+"y: "+average.y);
    }
  }
  stroke(255);
  strokeWeight(0.1);
  //translate(-810, 0);
  
  
  //projector points
  //arrayCopy(vectors_backup,vectors);
  int ii = 0;
  for (Contour contour : contours) {
    if (contour.area()>max_area*contourT && contour.area()<kinect2.depthWidth*kinect2.depthHeight*sigma && contour.getPoints().size()>contourSize) {
      for (PVector point : contour.getPoints()) {
        //PVector p = new PVector(point.x, point.y);
        //PVector p = depthMap[(int)point.x+(int)point.y*kinect2.depthWidth];
        //PVector ProjectorCoord = convertKinectToProjector(p);
        //int x = round(ProjectorCoord.x);
        //int y = round(ProjectorCoord.y);
        //int x = round(p.x);
        //int y = round(p.y);
        int x = round(point.x/kinect2.depthWidth*pWidth);
        int y = round(point.y/kinect2.depthHeight*pHeight);
        //println("x: " + x + " y: " + y);
        if (x>=0 && x<pWidth && y>=0 && y<pHeight && center.size()>=ii+1) {
          //println("find the target");
          //float sum = sqrt(pow(x-center.get(ii).x,2)+pow(y-center.get(ii).y,2));
          //vectors[x][y].x = -(x-center.get(ii).x)/sum;
          //vectors[x][y].y = -(y-center.get(ii).y)/sum;
          //vecChange.add(new PVector(x,y));
          //line(x,y,center.get(ii).x,center.get(ii).y);
          int kernalSize = 2;
          for (int i = -kernalSize; i <= kernalSize; i++) {
            for (int j = -kernalSize; j <= kernalSize; j++) {
              if (x+i >= 0 && x+i < pWidth && y+j >= 0 && y+j < pHeight) {
               vectors[x+i][y+j].x = (-i/kernalSize);
               vectors[x+i][y+j].y = (-j/kernalSize);
               vecChange.add(new PVector(x+i,y+j));
              }
          }
  }
        }
      }
      ii++;
    }
  }
  //println("size: "+center.size());
  center.clear();
}
