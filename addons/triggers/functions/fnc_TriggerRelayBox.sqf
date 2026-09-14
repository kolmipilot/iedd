#include "..\script_component.hpp"
/*
 * Author: kolmipilot
 * 
 * Handles triggering and networking for relay boxes.
 *
 * Arguments:
 * 0: RelayBox object <OBJECT>
 * 1: Source object <OBJECT>
 * 2: Time to live (remain amounts of hops) <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_relayBox, _source, _ttl] call iedd_triggers_fnc_TriggerRelayBox;
 *
 * Public: No
 */
params ["_target", "_source", "_ttl"];

if (isNull _target) exitWith {};

TRACE_3("TriggerRelayBox",_target,_source,_ttl);

private _connectionData = _target getVariable ["IEDD_Links", []];
if (_connectionData isEqualType "") then {
    _connectionData = parseSimpleArray _connectionData;
};

private _relayBoxes = [];
private _ieds = [];
{
    if !(_x isEqualType []) exitWith {};

    private _connectionType = _x param [0, ""];
    if (_connectionType == "box") then {
        private _position = _x param [1, []];
        if (_position isEqualType [] && {count _position == 3}) then {
            _relayBoxes pushBack nearestObject [_position, QGVAR(RelayBox)];
        };
    };

    if (_connectionType == "ied") then {
        private _className = _x param [1, ""];
        private _position = _x param [2, []];
        if (_className isEqualType "" && {_className != ""} && {_position isEqualType []} && {count _position == 3}) then {
            _ieds pushBack nearestObject [_position, _className];
        };
    };
} forEach _connectionData;
TRACE_3("TriggerRelayBox connections",_relayBoxes,_ieds,_connectionData);
{
    if (!isNull _x && {_x != _source} && {_ttl > 0}) then {
        [_x, _target, (_ttl - 1)] call FUNC(TriggerRelayBox);
    };
} forEach _relayBoxes;
{
    [_x] call iedd_ied_fnc_bomb;
} forEach _ieds;
