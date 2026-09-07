class CBA_Extended_EventHandlers;
class CfgVehicles {
    class All;
    class Static: All {};
    class Building: Static {};
    class NonStrategic: Building {};
    class Wall: NonStrategic {};
    class Wall_F: Wall {};
    class Land_WoodenWall_03_s_pole_F: Wall_F {};
    class GVAR(TripWirePoleEnd): Land_WoodenWall_03_s_pole_F {
        scope = 2;
        scopeCurator = 0;
        displayName = CSTRING(TripWirePoleEnd_DisplayName);
        editorCategory = "IEDD_MAINCATEGORY";
        editorSubcategory = "IEDD_TRIGGERS";
    };
    class GVAR(TripWirePole): GVAR(TripWirePoleEnd) {
        displayName = CSTRING(TripWirePole_DisplayName);
        class EventHandlers
        {
            class CBA_Extended_EventHandlers: CBA_Extended_EventHandlers {};
            class GVAR(TripWirePole_EventHandlers)
            {
                //init = QUOTE(call FUNC(SpawnTripWireInit));
                init = QUOTE( \
                if (isNil 'QQFUNC(SpawnTripWireInit)') then { \
                    call compile preProcessFileLineNumbers 'x\iedd\addons\triggers\functions\fnc_SpawnTripWireInit.sqf'; \
                }; \
                _this call FUNC(SpawnTripWireInit); \
                );
            };
        };
        class Attributes {
            class IEDD_TripWireConnections {
                displayName = "Tripwire connections";
                property = "iedd_triggers_connections";
                control = "Edit";
                defaultValue = "[]";
                typeName = "ARRAY";
                expression = "_this setVariable ['IEDD_Links', _value, true];";
                condition = "script";
                conditionScript = "false";
            };
        };
    };
};
