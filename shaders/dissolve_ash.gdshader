shader_type canvas_item;
render_mode unshaded;
uniform float progress : hint_range(0.0,1.0) = 0.0;
uniform vec4 frame_bounds = vec4(0.0,0.0,1.0,1.0);
uniform vec2 vertical_bounds = vec2(0.0,1.0);
uniform sampler2D sombra_transformacao : filter_linear;
varying vec4 actor_tint;
void vertex(){ actor_tint=COLOR; }
void fragment(){
 vec4 paint=texture(TEXTURE,UV);
 vec2 local=(UV-frame_bounds.xy)/max(frame_bounds.zw-frame_bounds.xy,vec2(0.00001));
 float grain=fract(sin(dot(floor(local*100.0),vec2(12.9898,78.233)))*43758.5453);
 float mask=texture(sombra_transformacao,vec2(local.x/6.0+2.0/6.0,local.y)).a;
 float height=(local.y-vertical_bounds.x)/max(vertical_bounds.y-vertical_bounds.x,0.0001);
 float edge=1.0-height+grain*0.12+mask*0.06;
 float keep=progress<=0.0?1.0:smoothstep(progress-0.03,progress+0.03,edge);
 if(progress>=1.0){keep=0.0;}
 float ash=progress>0.0?1.0-smoothstep(0.0,0.10,abs(edge-progress)):0.0;
 vec3 color=mix(paint.rgb,vec3(0.48,0.44,0.40),ash*0.8);
 COLOR=vec4(color*actor_tint.rgb,paint.a*keep*actor_tint.a);
}
