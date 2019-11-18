#include <a_samp>
#include <YSI_Data\y_iterate>

/**constants*/
#define max_tracks                  100
#define max_trackpoints             6000
#define trackpoints_per_track       60 

#define track_max_exceeded          -1
#define invalid_track_type          -2
#define trackpoint_max_exceeded     -3
#define invalid_parent_id           -4

/**array information*/
enum eTrack{
    sid,
    Type,
    Desc[32]
};
new Track[max_tracks][eTrack],
    Iterator:fTracks<max_tracks>;

enum eTrackPoint{
    sid,
    ParentSid,
    Index,
    Float:Pos[3]
};
new TrackPoint[max_trackpoints][eTrackPoint],
    Iterator:fTrackPoints<max_trackpoints>;

static const aTracksTypes[][20] = {"Race"};

/**funcinality*/
bool:isValidTrackType(type){
    return (0 <= type < sizeof(aTracksTypes));
}

getTrackTypeName(type){
    return isValidTrackType(type) ? aTracksTypes[type] : ("");
}

stock addTrack(const desc[32], type){
    if(!isValidTrackType(type))return invalid_track_type;
    new i = Iter_Free(fTracks);
    if(i == INVALID_ITERATOR_SLOT) return track_max_exceeded;
    Iter_Add(fTracks, i);
    Track[i][Desc] = desc;
    Track[i][Type] = type;
    return i;
}

stock addTrackPoint(parentID, const Float:pos[3]){
    if(!Iter_Contains(fTracks, parentID))return invalid_parent_id;
    new i = Iter_Free(fTrackPoints);
    if(i == INVALID_ITERATOR_SLOT) return trackpoint_max_exceeded;
    new nextIndex = findEmptyTrackPointIndex(Track[parentID][sid]);
    if(nextIndex == -1)return trackpoint_max_exceeded;
    Iter_Add(fTrackPoints, i);
    TrackPoint[i][ParentSid] = Track[parentID][sid];
    TrackPoint[i][Pos] = pos;
    TrackPoint[i][Index] = nextIndex;
    return i;
}

bool:isValidTrackPoint(parentSid, index){
    foreach(new i : fTrackPoints){
        if(TrackPoint[i][ParentSid] == parentSid && TrackPoint[i][Index] == index)return true;
    }
    return false;
}

findEmptyTrackPointIndex(parentSid){
    for(new i; i < trackpoints_per_track; i++){
        if(!isValidTrackPoint(parentSid, i))return i;
    }
    return -1;
}

testing(){
    new res1 = addTrack("init", 0);
    new res2 = addTrackPoint(res1, Float:{0.0, 0.0, 0.0});
    printf("debug_races: %d %d %s", res1, res2, getTrackTypeName(Track[res1][Type]));
    return 1;
}

main(){}

public OnGameModeInit(){
    testing();
    return 1;
}

public OnGameModeExit(){
    return 1;
}