import Foundation
import CoreBluetooth

class IQOS: NSObject {
    var modelNumber: String = ""
    var customeName: String = ""
    var serialNumber: String = ""
    var softwareRevision: String = ""
    var manufacturerName: String = ""
    var chargerBatteryState: UInt8 = 0
    var scpCharacteristicUUID: CBUUID?
    var peripheral: CBPeripheral?
    var scp_chara: CBCharacteristic?

    func setChargerBattery(characteristic: CBCharacteristic) {
        chargerBatteryState = characteristic.value![2]
    }

    var isFullyfilled: Bool {
        return modelNumber != "" && serialNumber != "" && softwareRevision != "" && manufacturerName != ""
    }
    var fullyfilledHandler: (() -> Void)?

    func initFromCharacteristic(characteristic: CBCharacteristic) {
        switch "\(characteristic.uuid)"
        {
            case "Model Number String", "Serial Number String", "Software Revision String", "Manufacturer Name String":
                modelNumber = String(decoding: characteristic.value ?? Data(), as: UTF8.self)

            // for charger battery capacity
            case "F8A54120-B041-11E4-9BE7-0002A5D5C51B":
                // example
                // ["0f", "00", "4b", "18", "54", "0f", "64"]
                //               ↑ indicate battery level

                setChargerBattery(characteristic: characteristic)

            case "E16C6E20-B041-11E4-A4C3-0002A5D5C51B":
                scp_chara = characteristic

            default:
                print("Unknown characteristic \(characteristic.uuid)")
        }
    }
}

class IQOSIlumaI: IQOS {
    func toBrightnessHigh() {
        // let first: Data = Data([0x00, 0xc0, 0x01, 0x21, 0xf2])
        // let second: Data = Data([0x00, 0xc0, 0x00, 0x00, 0x01, 0x07])
        // let third: Data = Data([0x00, 0xc0, 0x04, 0x06, 0x01, 0x00, 0x00, 0x00, 0xf9])
        // let fourth: Data = Data([0x00, 0xc0, 0x01, 0x00, 0x15])
        // let fifth: Data = Data([0x00, 0xc0, 0x46, 0x23, 0x64, 0x00, 0x00, 0x00, 0x4f])
        // peripheral.writeValue(first, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        // peripheral.writeValue(second, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        // peripheral.writeValue(third, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        // peripheral.writeValue(fourth, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        // peripheral.writeValue(fifth, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        let payload: Data = Data([0x00, 0xc0, 0x46, 0x23, 0x64, 0x00, 0x00, 0x00, 0x4f])
        peripheral?.writeValue(payload, for: scp_chara!, type: .withResponse)
    }

    func toBrightnessLow() {
        let payload: Data = Data([0x00, 0x08, 0x84, 0x24, 0x1e, 0x00, 0x00, 0x00, 0x00])
        peripheral?.writeValue(payload, for: scp_chara!, type: .withResponse)
    }

    func enableSmartgesture() {
        let first: Data = Data([0x00, 0xc9, 0x48, 0x05, 0x3c, 0x05, 0x01, 0x00, 0x00, 0x01, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0xc0])
        let second: Data = Data([0x00, 0xc9, 0x04, 0x05, 0x05, 0x01, 0x00, 0x00, 0x6c])
        let third: Data = Data([0x00, 0xc9, 0x44, 0x05, 0x00, 0xff, 0xff, 0x00, 0xc3])

        peripheral?.writeValue(first, for: scp_chara!, type: .withResponse)
        peripheral?.writeValue(second, for: scp_chara!, type: .withResponse)
        peripheral?.writeValue(third, for: scp_chara!, type: .withResponse)
    }
    func disableSmartgesture() {
        // 21:47:70100
        let first: Data = Data([0x00, 0xc9, 0x48, 0x05, 0x2f, 0x05, 0x01, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0xeb])
        let second: Data = Data([0x00, 0xc9, 0x44, 0x05, 0x00, 0xff, 0xff, 0x00, 0xc3])
        let third: Data = Data([0x00, 0xc9, 0x04, 0x05, 0x05, 0x01, 0x00, 0x00, 0x6c])

        peripheral?.writeValue(first, for: scp_chara!, type: .withResponse)
        peripheral?.writeValue(second, for: scp_chara!, type: .withResponse)
        peripheral?.writeValue(third, for: scp_chara!, type: .withResponse)
        // peripheral.writeValue(payload, for: characteristic, type: .withResponse)
    }
}