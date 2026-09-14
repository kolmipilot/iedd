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
 * [_pole] call iedd_triggers_fnc_SpawnRelayBoxInit;
 *
 * Public: No
 */
params ["_obj"];

TRACE_2("fnc_SpawnRelayBoxInit",_this,is3DEN);

if (isNull _obj) exitWith {};
if (!is3DEN) exitWith {_obj call FUNC(SpawnRelayBoxHandle)};

_obj addEventHandler ["ConnectionChanged3DEN", {
    params ["_object"];
    TRACE_1("ConnectionChanged3DEN",_object);
    [_object] call FUNC(UpdateRelayBoxConnection);
}];

_obj addEventHandler ["UnregisteredFromWorld3DEN", {
    params ["_object"];
    TRACE_1("UnregisteredFromWorld3DEN",_object);
    private _wire = _object getVariable ["IEDD_3denWire", -1];
    if (_wire >= 0) then {
        removeMissionEventHandler ["Draw3D", _wire];
    };
}];

_obj addEventHandler ["RegisteredToWorld3DEN", {
    params ["_object"];
    TRACE_1("RegisteredToWorld3DEN",_object);
    [_object] call FUNC(UpdateRelayBoxConnection);
}];

[_obj] call FUNC(UpdateRelayBoxConnection);
