# Tech debt: narrow dependency injection

After split of `LimitLoginAttempts`, several services still accept the full facade:

- `LocalLockoutManager( LimitLoginAttempts $plugin )`
- `DashboardRiskRenderer( LimitLoginAttempts $plugin, ... )`
- `AdminUiController( LimitLoginAttempts $plugin )`
- `RegistrationLimiter( LimitLoginAttempts $plugin )`

**Follow-up:** replace with callables or small interfaces (`OptionsPageUriProvider`, `PluginInfoProvider`) so services do not depend on the 1500+ line facade.

**Target facade size:** ≤600 LOC (orchestration + public API proxies only).
