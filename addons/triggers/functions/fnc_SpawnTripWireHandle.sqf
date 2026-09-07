#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * 
 * Handling Trip Wire functions in mission
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

params ["_pole1", "_pole2Position", ["_iedData", []]];

[{
    params ["_pole1", "_pole2Position", ["_iedData", []]];


    TRACE_3("SpawnTripWireHandle",_pole1,_pole2Position,_iedData);

    if (isNull _pole1 || {!(_pole2Position isEqualType [])}) exitWith {};

    private _pole2 = nearestObject [_pole2Position, QGVAR(TripWirePoleEnd)];
    if (isNull _pole2) exitWith {};

    private _ieds = [];
    {
        _x params ["_className", "_position"];
        private _ied = nearestObjects [_position, [_className], 2] param [0, objNull];
        if (!isNull _ied) then {
            _ieds pushBackUnique _ied;
        };
    } forEach _iedData;
    private _mehTrip = addMissionEventHandler ["Draw3D", {
        _thisArgs params ["_p1", "_p2"];
        
        if (!isNull _p1 && !isNull _p2) then {
            private _pos1 = getPosATL _p1;
            private _pos2 = getPosATL _p2;
            _pos1 set [2, 0.1];
            _pos2 set [2, 0.1];
            drawLine3D [_pos1, _pos2, [0,0,0,1], 2];
        };
    }, [_pole1, _pole2]];

    private _midpoint = (getPosASL _pole1 vectorAdd getPosASL _pole2) vectorMultiply 0.5;
    private _distance = _pole1 distance _pole2;
    private _dirLine = _pole1 getDir _pole2;

    private _trg = objNull;
    if (isServer) then {
        _trg = createTrigger ["EmptyDetector", _midpoint, false];
        _trg setTriggerArea [0.1, _distance / 2, _dirLine, true];
        _trg setPosASL _midpoint;
        _trg setTriggerActivation ["ANYPLAYER", "PRESENT", false];
        _trg setTriggerStatements [
            "this",
            "private _tripIEDs = thisTrigger getVariable ['IEDD_TriggerIEDs', []];private _tripWirehandler = thisTrigger getVariable ['IEDD_tripwire_handler', -1]; {[_x] call iedd_ied_fnc_bomb;} forEach _tripIEDs; if (_tripWirehandler != -1) then { removeMissionEventHandler ['Draw3D', _tripWirehandler]; if (!isNull thisTrigger) then { deleteVehicle thisTrigger; };};",
            ""
        ];
        _trg setTriggerInterval 0.1;
        _trg setVariable ["IEDD_TriggerIEDs", _ieds, true];
        _trg setVariable ["IEDD_tripwire_handler", _mehTrip];
    };

    private _pos1 = getPosASL _pole1;
    _pos1 set [2, (_pos1 select 2) + 0.1];
    private _dirPoles = _pole2 getDir _pole1;

    private _igniter = createVehicle ["Land_BatteryPack_01_battery_black_F", [0,0,0], [], 0, "CAN_COLLIDE"];
    _igniter setPosASL _pos1;
    _igniter setDir _dirPoles;
    _igniter enableSimulationGlobal false;
    [_igniter, _pole1] call BIS_fnc_attachToRelative;

    _igniter setVariable ["IEDD_tripwire_handler", _mehTrip];
    _igniter setVariable ["IEDD_trigger", _trg, true];

    private _action = [
        "IeddLocalCutWire", 
        "Cut Wire", 
        "", 
        {
            params ["_target", "_player", "_args"];
            
            private _handler1 = _target getVariable ["IEDD_tripwire_handler", -1];
            private _trigger = _target getVariable ["IEDD_trigger", objNull];
            
            if (_handler1 != -1) then { removeMissionEventHandler ["Draw3D", _handler1]; };

            if (!isNull _trigger) then { deleteVehicle _trigger; };
            
            [CSTRING(CutWire), false, 5, 2] call ace_common_fnc_displayText
        }, 
        {params ["_target", "_caller"];! (isNull(_target getVariable ["IEDD_trigger", objNull]))}, 
        {}, 
        []
    ] call ace_interact_menu_fnc_createAction;

    [_igniter, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;


}, [_pole1, _pole2Position, _iedData]] call CBA_fnc_execNextFrame;
