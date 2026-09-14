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
 * [_pole] call iedd_triggers_fnc_SpawnTripWireInit;
 *
 * Public: No
 */
params ["_obj"];

TRACE_2("fnc_SpawnTripWireIgniterEdenOrMission",_this,is3DEN);

if (isNull _obj) exitWith {};
if (!is3DEN) exitWith {_obj call FUNC(SpawnTripWireHandle)};

private _igniter = createSimpleObject ["Land_BatteryPack_01_battery_black_F", [0, 0, 0], true];
_igniter setPosASL [getPosASL _obj select 0, getPosASL _obj select 1, (getPosASL _obj select 2) + 0.1];
[_igniter, _obj] call BIS_fnc_attachToRelative;
_obj setVariable ["IEDD_3denIgniter", _igniter];

_obj addEventHandler ["ConnectionChanged3DEN", {
    params ["_object"];
    TRACE_1("ConnectionChanged3DEN",_object);
    [_object] call FUNC(UpdateTripWireConnection);
}];

_obj addEventHandler ["Dragged3DEN", {
    params ["_object"];
    TRACE_1("Dragged3DEN",_object);
    private _igniter = _object getVariable ["IEDD_3denIgniter", objNull];
    if (!isNull _igniter) then {
        _igniter setPos [getPos _object select 0, getPos _object select 1, (getPos _object select 2) + 0.1];
    };
}];

_obj addEventHandler ["UnregisteredFromWorld3DEN", {
    params ["_object"];
    TRACE_1("UnregisteredFromWorld3DEN",_object);
    private _igniter = _object getVariable ["IEDD_3denIgniter", objNull];
    if (!isNull _igniter) then {
        deleteVehicle _igniter;
    };
    private _wire = _object getVariable ["IEDD_3denWire", -1];
    if (_wire >= 0) then {
        removeMissionEventHandler ["Draw3D", _wire];
    };
}];

_obj addEventHandler ["RegisteredToWorld3DEN", {
    params ["_object"];
    TRACE_1("RegisteredToWorld3DEN",_object);
    [_object] call FUNC(UpdateTripWireConnection);
}];

[_obj] call FUNC(UpdateTripWireConnection);
