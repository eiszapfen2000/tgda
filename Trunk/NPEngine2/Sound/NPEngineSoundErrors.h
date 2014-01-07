#ifndef NPENGINESOUNDERRORS_H_
#define NPENGINESOUNDERRORS_H_

enum
{
    NPEngineSoundErrorMinimum = 1024,
    NPEngineSoundErrorMaximum = 2047,
    NPOpenALErrorMinimum = 1024,
    NPOpenALErrorMaximum = 1151,
    NPOpenALError = 1024,
    NPOpenALCError = 1025,
    NPVorbisErrorMinimum = 1152,
    NPVorbisErrorMaximum = 1279,
    NPVorbisReadError = 1152,
    NPVorbisStreamNotVorbisError = 1153,
    NPVorbisVersionMismatchError = 1154,
    NPVorbisBadHeaderError = 1155,
    NPVorbisInternalError = 1156,
    NPVorbisHoleError = 1157,
    NPVorbisBadLinkError = 1158,
    NPVorbisBadInputError = 1159,
    NPVorbisNumberOfChannelsError = 1160
};

#endif
