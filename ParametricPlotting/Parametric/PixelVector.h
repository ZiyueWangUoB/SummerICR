#ifndef PIXELVECTOR_H
#define PIXELVECTOR_H

#include <vector>
using namespace std;


class PixelVector
{
public:
    PixelVector(int xCoord, int yCoord, vector intensity);

    //Setters and getters
    int GetXCoord(){
        return _xCoord;
    }

    int GetYCoord(){
        return _yCoord;
    }

    void SetXCoord(int x){
        _xCoord = x;
    }

    void SetYCoord(int y){
        _yCoord = y;
    }


private:
    int _xCoord, _yCoord;
    vector<double> _intensity;

};

#endif // PIXELVECTOR_H
