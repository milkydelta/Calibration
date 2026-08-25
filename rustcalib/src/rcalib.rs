use dlt::{dlt_corresponding, CorrespondingPoint};
use godot::prelude::*;

use cam_geom::{Camera};

#[derive(GodotClass)]
#[class(init)]
struct RCalib;


#[godot_api]
impl RCalib {
    #[func]
    fn do_thing() {
        godot_print!("How's it going?");
    }
    #[func]
    fn do_dlt(world_points: PackedVector3Array, screen_points: PackedVector2Array) -> PackedFloat32Array {
        godot_print!("How's it going?");
        let mut c_points = Vec::<CorrespondingPoint<f32>>::with_capacity(12);
        let w_points = world_points.subarray(0..11).to_vec();
        let s_points = screen_points.subarray(0..11).to_vec();
        for (i, &item) in w_points.iter().enumerate() {
            let stem = s_points[i];
            c_points.push(CorrespondingPoint {
                object_point: [item.x, item.y, item.z],
                image_point: [stem.x, stem.y],
            });
        }
        print!("{:?}\n",c_points);
        let mat = dlt_corresponding(&c_points, 1e-10).unwrap();
        print!("{}\n",mat);

        let cam = Camera::from_perspective_matrix(&mat).unwrap();

        let mut outv = Vec::<f32>::with_capacity(7);

        outv.push(cam.extrinsics().translation().x);
        outv.push(cam.extrinsics().translation().y);
        outv.push(cam.extrinsics().translation().z);
        outv.push(cam.extrinsics().pose().rotation.into_inner().coords.x);
        outv.push(cam.extrinsics().pose().rotation.into_inner().coords.y);
        outv.push(cam.extrinsics().pose().rotation.into_inner().coords.z);
        outv.push(cam.extrinsics().pose().rotation.into_inner().coords.w);
        print!("{:?}\n",outv);

        print!("{}\n", cam.intrinsics().fx());
        print!("{}\n", cam.intrinsics().fy());
        print!("{}\n", cam.intrinsics().cx());
        print!("{}\n", cam.intrinsics().cy());

        return PackedFloat32Array::from(outv);
    }
}
