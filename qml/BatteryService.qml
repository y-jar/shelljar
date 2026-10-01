/***
 *  ╃
 *  .▀▀█▀▀ .
 *     :▓:.
 *  .▀▀ : ╃
 *   shelljar
 *
 *   BatteryService
 *
 *   Normalises UPower for the whole shell. Quickshell exposes device charge as
 *   a 0.0-1.0 fraction (UPower's 0-100 Percentage times 0.01) while health stays
 *   0-100, so everything battery related funnels through here and comes back as
 *   a friendly 0-100 percent. On laptops with more than one battery (a ThinkPad
 *   with a slice pack, say) the aggregate is energy weighted across the cells
 *   instead of trusting UPower's own display device, and the low / critical
 *   flags are answered once so the pill and the panel never disagree.
 ***/
pragma Singleton
import QtQuick
import Quickshell.Services.UPower

Item {
  id: root

  // physical laptop batteries only (drops line power, mice, phones, ...)
  readonly property var batteries: {
    const all = (UPower.devices && UPower.devices.values) ? UPower.devices.values : []
    return all.filter(b => b && b.isLaptopBattery)
  }

  readonly property bool present: batteries.length > 0
  readonly property bool ready: batteries.some(b => b.ready)

  readonly property bool charging: batteries.some(b =>
    b.state === UPowerDeviceState.Charging
    || b.state === UPowerDeviceState.PendingCharge
    || b.state === UPowerDeviceState.FullyCharged)

  // aggregate charge as 0-100: energy weighted when capacities are known,
  // otherwise the mean of each cell's percentage (both handle dual batteries)
  readonly property real percent: {
    if (!root.present) return 0
    let energy = 0
    let capacity = 0
    for (const b of root.batteries) {
      if (!b.ready) continue
      energy += b.energy
      capacity += b.energyCapacity
    }
    if (capacity > 0) return clamp((energy * 100) / capacity)

    const usable = root.batteries.filter(b => b.ready && b.percentage >= 0)
    if (usable.length === 0) return 0
    let sum = 0
    for (const b of usable) sum += b.percentage * 100
    return clamp(sum / usable.length)
  }

  // health is already reported 0-100 (UPower "Capacity")
  readonly property bool healthSupported: UPower.displayDevice !== null && UPower.displayDevice.healthSupported
  readonly property real healthPercent: root.healthSupported ? UPower.displayDevice.healthPercentage : 0

  readonly property bool low: root.present && !root.charging && root.percent <= Config.batteryLow
  readonly property bool critical: root.present && !root.charging && root.percent <= Config.batteryCritical

  // per-device charge as 0-100, for the panel that lists each battery
  function percentOf(device) {
    return device ? Math.round(clamp(device.percentage * 100)) : 0
  }

  function clamp(value) {
    return Math.max(0, Math.min(100, value))
  }
}
