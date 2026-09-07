#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * 
 *
 * Arguments:
 * 0: TripWirePole object <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_pole] call iedd_triggers_fnc_SpawnTripWireIgniter;
 *
 * Public: No
 */
params ["_object"];

if (!is3DEN || {isNull _object}) exitWith {};

private _pole2 = objNull;
private _ieeds = [];
{
    private _connectedObject = _x select 1;
    if (typeOf _connectedObject == QGVAR(TripWirePoleEnd)) then {
        _pole2 = _connectedObject;
    };
    if ((typeOf _connectedObject) in IEDD_CLASSES || (typeOf _connectedObject) in IEDD_FAKE_CLASSES) then {
        _ieeds pushBack [typeOf _connectedObject, getPos _connectedObject];
    };
} forEach get3DENConnections _object;

private _init = "";//_object get3DENAttribute "init" param [0, ""];
if (!isNull _pole2) then {
    _init = _init + format [";[this, %1, %2] call iedd_triggers_fnc_SpawnTripWireHandle;", str getPos _pole2, str _ieeds];
};
_object set3DENAttribute ["init", _init];

private _oldWire = _object getVariable ["IEDD_3denWire", -1];
if (_oldWire >= 0) then {
    removeMissionEventHandler ["Draw3D", _oldWire];
};

if (isNull _pole2) exitWith {
    _object setVariable ["IEDD_3denWire", -1];
};

private _wire = addMissionEventHandler ["Draw3D", {
    _thisArgs params ["_p1", "_p2"];
    if (isNull _p1 || isNull _p2) exitWith {
        removeMissionEventHandler ["Draw3D", _thisEventHandler];
    };

    private _pos1 = getPos _p1;
    private _pos2 = getPos _p2;
    _pos1 set [2, 0.1];
    _pos2 set [2, 0.1];
    drawLine3D [_pos1, _pos2, [0, 0, 0, 1], 2];
}, [_object, _pole2]];

_object setVariable ["IEDD_3denWire", _wire];
