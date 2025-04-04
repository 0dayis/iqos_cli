use super::error::{IQOSError, Result};
use btleplug::platform::Peripheral;
use btleplug::api::{Peripheral as _, Service, Characteristic};
use anyhow::Context;
use std::option::Option;
use std::fmt;

pub struct IQOS {
    modelnumber: String,
    serialnumber: String,
    softwarerevision: String,
    manufacturername: String,
    holder_battery_level: u8,
    scp_characteristic_uuid: String,
    peripheral: Peripheral,
}

impl IQOS {
    pub(crate) fn new(
        peripheral: Peripheral,
        modelnumber: String,
        serialnumber: String,
        softwarerevision: String,
        manufacturername: String,
    ) -> Self {
        Self {
            peripheral,
            modelnumber,
            serialnumber,
            softwarerevision,
            manufacturername,
            holder_battery_level: 0,
            scp_characteristic_uuid: String::new(),
        }
    }

    pub fn model_number(&self) -> &str {
        &self.modelnumber
    }

    pub fn serial_number(&self) -> &str {
        &self.serialnumber
    }

    pub fn software_revision(&self) -> &str {
        &self.softwarerevision
    }

    pub fn manufacturer_name(&self) -> &str {
        &self.manufacturername
    }

    pub fn battery_level(&self) -> u8 {
        self.holder_battery_level
    }

    pub async fn disconnect(&mut self) -> Result<()> {
        let peripheral = self.peripheral.clone();
        
        peripheral.disconnect().await
            .map_err(IQOSError::BleError)
    }


    pub async fn initialize(&mut self) -> Result<()> {
        self.peripheral.discover_services().await
            .map_err(IQOSError::BleError)?;
        
        for service in self.peripheral.services() {
            for characteristic in service.characteristics {
                if characteristic.uuid.to_string().starts_with("FFE9") {
                    self.scp_characteristic_uuid = characteristic.uuid.to_string();
                    break;
                }
            }
        }

        self.update_device_info().await?;
        Ok(())
    }

    async fn update_device_info(&mut self) -> Result<()> {
        // ここでデバイスの情報を取得して各フィールドを更新
        // モデル番号、シリアル番号、ソフトウェアバージョン、製造者名など
        // 実際の実装はデバイスのプロトコルに依存します
        
        Ok(())
    }
} 

impl fmt::Display for IQOS {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f,
            "Model Number: {}\nSerial Number: {}\nSoftware Revision: {}\nManufacture Name: {}",
            self.modelnumber,
            self.serialnumber,
            self.softwarerevision,
            self.manufacturername,
        )
    }
}