"""Single Shipment Tracking for Trucked Goods."""

import from byllm.llm {Model}


glob llm = Model(model_name="gemini/gemini-2.0-flash", verbose=False);


def generate_shipment_status(goods_type: str, stage_name: str) -> str by llm();


walker ShipmentAgent {
    has goods_type: str;
    has shipment_id: int;

    can start with `root entry;
    can advance_stage with shipment_stage entry;
}

node shipment_stage {
    has stage_name: str;
}


with entry {

    # Define shipment stages
    loaded = shipment_stage(stage_name="LOADED_AT_WAREHOUSE");
    en_route = shipment_stage(stage_name="IN_TRANSIT");
    checkpoint = shipment_stage(stage_name="AT_CHECKPOINT");
    delivered = shipment_stage(stage_name="DELIVERED_TO_DESTINATION"); 

    root ++> loaded ++> en_route ++> checkpoint ++> delivered;

    # Spawn shipments
    root spawn ShipmentAgent(goods_type="Household Items", shipment_id=1);
    root spawn ShipmentAgent(goods_type="Foodstuffs", shipment_id=2);
    root spawn ShipmentAgent(goods_type="Building Materials", shipment_id=3);
    root spawn ShipmentAgent(goods_type="Clothes", shipment_id=4);
    
}


impl ShipmentAgent.start {
    visit [root --> (`?shipment_stage)];
}

impl ShipmentAgent.advance_stage {
    current_stage = here.stage_name;
    status_message = generate_shipment_status(self.goods_type, current_stage);
    print(f"SHIPMENT {self.shipment_id}: {status_message}");

    
    if current_stage != "DELIVERED_TO_DESTINATION" {
        input(f"--- Press ENTER to move {self.goods_type} shipment to the next stage... ---");
        visit [-->];
    } else {
        print(f"SHIPMENT {self.shipment_id} : {self.goods_type} delivery workflow is complete.");
        disengage; 
    }
}
