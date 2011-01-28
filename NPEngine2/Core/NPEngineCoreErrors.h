#ifndef NPENGINECORERRORS_H_
#define NPENGINECORERRORS_H_

enum
{
    NPEngineCoreErrorMinimum = 0,
    NPEngineCoreErrorMaximum = 1023,
    NPStreamErrorMinimum = 0,
    NPStreamErrorMaximum = 127,
    NPStreamOpenError = 0,
    NPStreamCloseError = 10,
    NPStreamReadError = 20,
    NPStreamWriteError = 30,
    NPPathErrorMinimum = 128,
    NPPathErrorMaximum = 255,
    NPPathFileNotFoundError = 128
};

#endif

