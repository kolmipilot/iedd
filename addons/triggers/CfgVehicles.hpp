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
            class GVAR(TripWirePole_EventHandlers)
            {
                init = QUOTE(call FUNC(SpawnTripWireInit));
            };
        };
    };
};
