package org.papervision3d.core.render.command
{

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import org.papervision3d.core.Number3D;
	import org.papervision3d.core.geom.renderables.IRenderable;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3DInstance;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.hit.RenderHitData;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.utils.InteractiveUtils;
	
	public class RenderTriangle extends RenderableListItem implements IRenderListItem
	{
		//Avoiding vars in the main loop.
		private static var container:Sprite;
		private static var renderMat:MaterialObject3D;
		
		public var triangle:Triangle3D;
		public var container:Sprite;
		
		public function RenderTriangle(triangle:Triangle3D):void
		{
			this.triangle = triangle;
			renderableInstance = triangle;
			renderable = Triangle3D;
		}
		
		override public function render(renderSessionData:RenderSessionData):void
		{
			container = triangle.instance.container ? triangle.instance.container : renderSessionData.container;
			renderMat = triangle.material ? triangle.material : triangle.instance.material;
			renderMat.drawFace3D(triangle, container.graphics, triangle.v0.vertex3DInstance, triangle.v1.vertex3DInstance, triangle.v2.vertex3DInstance);
		}
		
		override public function hitTestPoint2D(point:Point):RenderHitData
		{
			var vPoint:Vertex3DInstance = new Vertex3DInstance(point.x, point.y);
			var vx0:Vertex3DInstance = triangle.v0.vertex3DInstance;
			var vx1:Vertex3DInstance = triangle.v1.vertex3DInstance;
			var vx2:Vertex3DInstance = triangle.v2.vertex3DInstance;
			if(sameSide(vPoint,vx0,vx1,vx2)){
				if(sameSide(vPoint,vx1,vx0,vx2)){
					if(sameSide(vPoint,vx2,vx0,vx1)){
						return deepHitTest(triangle, vPoint);
					}
				}
			}
			return null;
		}
		
		public function sameSide(point:Vertex3DInstance, ref:Vertex3DInstance, a:Vertex3DInstance, b:Vertex3DInstance):Boolean
		{
			var n:Number =  Vertex3DInstance.cross(Vertex3DInstance.sub(b,a), Vertex3DInstance.sub(point,a))*Vertex3DInstance.cross(Vertex3DInstance.sub(b,a), Vertex3DInstance.sub(ref,a));
			return n>0;
		}
		
		private function deepHitTest(face:Triangle3D, vPoint:Vertex3DInstance):RenderHitData
		{
			var v0:Vertex3DInstance = face.v0.vertex3DInstance;
			var v1:Vertex3DInstance = face.v1.vertex3DInstance;
			var v2:Vertex3DInstance = face.v2.vertex3DInstance;
			
			var v0_x : Number = v2.x - v0.x;
	        var v0_y : Number = v2.y - v0.y;
	        var v1_x : Number = v1.x - v0.x;
	        var v1_y : Number = v1.y - v0.y;
	        var v2_x : Number = vPoint.x - v0.x;
	        var v2_y : Number = vPoint.y - v0.y;
	        var dot00 : Number = v0_x * v0_x + v0_y * v0_y;
	        var dot01 : Number = v0_x * v1_x + v0_y * v1_y;
	        var dot02 : Number = v0_x * v2_x + v0_y * v2_y;
	        var dot11 : Number = v1_x * v1_x + v1_y * v1_y;
	        var dot12 : Number = v1_x * v2_x + v1_y * v2_y;
	        
	        var invDenom : Number = 1 / (dot00 * dot11 - dot01 * dot01);
			var u : Number = (dot11 * dot02 - dot01 * dot12) * invDenom;
			var v : Number = (dot00 * dot12 - dot01 * dot02) * invDenom;
			
			var rv0_x : Number = face.v2.x - face.v0.x;
	        var rv0_y : Number = face.v2.y - face.v0.y;
	        var rv0_z : Number = face.v2.z - face.v0.z;
	        var rv1_x : Number = face.v1.x - face.v0.x;
	        var rv1_y : Number = face.v1.y - face.v0.y;
			var rv1_z : Number = face.v1.z - face.v0.z;
			
			var hx:Number = face.v0.x + rv0_x*u + rv1_x*v;
			var hy:Number = face.v1.y + rv0_y*u + rv1_y*v;
			var hz:Number = face.v0.z + rv0_z*u + rv1_z*v;
			
			//From interactive utils
			var uv:Array = face.uv;
			var uu0 : Number = uv[0].u;
			var uu1 : Number = uv[1].u;
			var uu2 : Number = uv[2].u;
			var uv0 : Number = uv[0].v;
			var uv1 : Number = uv[1].v;
			var uv2 : Number = uv[2].v;
				
			var v_x : Number = ( uu1 - uu0 ) * v +  ( uu2 - uu0 ) * u + uu0;
			var v_y : Number = ( uv1 - uv0 ) * v +  ( uv2 - uv0 ) * u + uv0;

			renderMat = triangle.material ? face.material : face.instance.material;
			
			var bitmap:BitmapData = renderMat.bitmap;
			var width:Number = 1;
			var height:Number = 1;
			if(bitmap)
			{
				width = BitmapMaterial.AUTO_MIP_MAPPING ? renderMat.widthOffset : bitmap.width;
				height = BitmapMaterial.AUTO_MIP_MAPPING ? renderMat.heightOffset : bitmap.height;
			
			}
			//end from interactive utils
			
			var rhd:RenderHitData = new RenderHitData();
			rhd.displayObject3D = face.instance;
			rhd.renderable = face;
			
			rhd.x = hx;
			rhd.y = hy;
			rhd.z = hz;
			
			rhd.u = v_x * width;
			rhd.v = height - v_y * height;
			
			return rhd;
		}
		
		
		
	}
}