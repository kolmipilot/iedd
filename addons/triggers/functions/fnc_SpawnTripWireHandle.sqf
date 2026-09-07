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

params ["_pole1"];

[{
    params ["_pole1"];
    if (isNull _pole1) exitWith {};

    private _connectionData = _pole1 getVariable ["IEDD_Links", []];
    if !(_connectionData isEqualType []) exitWith {};

    private _pole2Position = [];
    private _iedData = [];
    {
        if !(_x isEqualType []) exitWith {};

        private _connectionType = _x param [0, ""];
        if (_connectionType == "pole") then {
            private _position = _x param [1, []];
            if (_position isEqualType [] && {count _position == 3}) then {
                _pole2Position = _position;
            };
        };

        if (_connectionType == "ied") then {
            private _className = _x param [1, ""];
            private _position = _x param [2, []];
            if (_className isEqualType "" && {_className != ""} && {_position isEqualType []} && {count _position == 3}) then {
                _iedData pushBack [_className, _position];
            };
        };
    } forEach _connectionData;

    if !(_pole2Position isEqualType [] && {count _pole2Position == 3}) exitWith {};
    private _pole2 = nearestObjects [_pole2Position, [QGVAR(TripWirePoleEnd)], 2] param [0, objNull];
    if (isNull _pole2) exitWith {};
    private _ieds = [];
    {
        if (_x isEqualType [] && {count _x == 2}) then {
            _x params ["_className", "_position"];
            if (_className isEqualType "" && {_className != ""} && {_position isEqualType []} && {count _position == 3}) then {
                private _ied = nearestObjects [_position, [_className], 2] param [0, objNull];
                if (!isNull _ied) then {
                    _ieds pushBackUnique _ied;
                };
            };
        };
    } forEach _iedData;

    TRACE_3("SpawnTripWireHandle",_pole1,_pole2,_ieds);

    if (isNull _pole1 || isNull _pole2) exitWith {};

    if (hasInterface) then {
        addMissionEventHandler ["Draw3D", {
            _thisArgs params ["_p1", "_p2"];

            if (isNull _p1 || isNull _p2 || {_p1 getVariable ["IEDD_TriggerActivated", false]}) exitWith {
                removeMissionEventHandler ["Draw3D", _thisEventHandler];
            };

            private _pos1 = getPosATL _p1;
            private _pos2 = getPosATL _p2;
            _pos1 set [2, 0.1];
            _pos2 set [2, 0.1];
            drawLine3D [_pos1, _pos2, [0,0,0,1], 2];
        }, [_pole1, _pole2]];
    };

    private _midpoint = (getPosASL _pole1 vectorAdd getPosASL _pole2) vectorMultiply 0.5;
    private _distance = _pole1 distance _pole2;
    private _dirLine = _pole1 getDir _pole2;

    private _trg = objNull;
    if (isServer) then {
        _pole1 setVariable ["IEDD_TriggerActivated", false, true];
        _trg = createTrigger ["EmptyDetector", _midpoint, false];
        _trg setTriggerArea [0.1, _distance / 2, _dirLine, true];
        _trg setPosASL _midpoint;
        _trg setTriggerActivation ["ANYPLAYER", "PRESENT", false];
        _trg setTriggerStatements [
            "this",
            "private _tripTrigger = thisTrigger; private _tripIEDs = _tripTrigger getVariable ['IEDD_TriggerIEDs', []]; private _tripPole = _tripTrigger getVariable ['IEDD_TriggerPole', objNull]; if (!isNull _tripPole) then {_tripPole setVariable ['IEDD_TriggerActivated', true, true]}; {[_x] call iedd_ied_fnc_bomb;} forEach _tripIEDs; deleteVehicle _tripTrigger;",
            ""
        ];
        _trg setTriggerInterval 0.1;
        _trg setVariable ["IEDD_TriggerIEDs", _ieds, true];
        _trg setVariable ["IEDD_TriggerPole", _pole1, true];
    };

    if (isServer) then {
        private _pos1 = getPosASL _pole1;
        _pos1 set [2, (_pos1 select 2) + 0.1];
        private _dirPoles = _pole2 getDir _pole1;
        private _igniter = createVehicle ["Land_BatteryPack_01_battery_black_F", [0,0,0], [], 0, "CAN_COLLIDE"];
        _igniter setPosASL _pos1;
        _igniter setDir _dirPoles;
        _igniter enableSimulationGlobal false;
        [_igniter, _pole1] call BIS_fnc_attachToRelative;
        _igniter setVariable ["IEDD_trigger", _trg, true];
        _igniter setVariable ["IEDD_TriggerPole", _pole1, true];
        _trg setVariable ["IEDD_TriggerIgniter", _igniter, true];
        _pole1 setVariable ["IEDD_TriggerIgniter", _igniter, true];
    };

    if (hasInterface) then {
        [{
            params ["_pole"];
            !isNull (_pole getVariable ["IEDD_TriggerIgniter", objNull])
        }, {
            params ["_pole"];
            private _igniter = _pole getVariable ["IEDD_TriggerIgniter", objNull];
            private _action = [
        "IeddLocalCutWire", 
        "Cut Wire", 
        "", 
            {
                params ["_target", "_player", "_args"];
            private _trigger = _target getVariable ["IEDD_trigger", objNull];
            if (!isNull _trigger) then { deleteVehicle _trigger; };
            _target setVariable ["IEDD_trigger", objNull, true];
            private _targetPole = _target getVariable ["IEDD_TriggerPole", objNull];
            if (!isNull _targetPole) then {_targetPole setVariable ["IEDD_TriggerActivated", true, true]};
            [CSTRING(CutWire), false, 5, 2] call ace_common_fnc_displayText
            },
            {params ["_target", "_caller"]; !isNull (_target getVariable ["IEDD_trigger", objNull])},
            {},
            []
            ] call ace_interact_menu_fnc_createAction;
            [_igniter, 0, ["ACE_MainActions"], _action] call ace_interact_menu_fnc_addActionToObject;
        }, [_pole1]] call CBA_fnc_waitUntilAndExecute;
    };


}, [_pole1]] call CBA_fnc_execNextFrame;
