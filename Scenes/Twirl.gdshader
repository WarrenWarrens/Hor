shader_type canvas_item;

// переменные анимаций
uniform float time_factor : hint_range(0.0, 5.0) = 1.0;
uniform float wave_strength : hint_range(0.0, 0.5) = 0.05;
uniform float ripple_speed : hint_range(0.0, 5.0) = 1.0;

// переменные визуала
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 edge_color : source_color = vec4(1.0, 0.5, 0.7, 1.0);
uniform float glow_intensity : hint_range(0.0, 5.0) = 1.5;
uniform float edge_pulse : hint_range(0.0, 2.0) = 1.0;

// переменные искажения
uniform sampler2D noise_tex : repeat_enable; 
uniform float noise_scale : hint_range(0.0, 5.0) = 1.0;
uniform float swirl_strength : hint_range(-2.0, 2.0) = 0.5;
uniform float hue_shift_speed : hint_range(0.0, 5.0) = 1.0;

// перегоняю в хсв для радуги
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	return vec3(abs((q.w - q.y)/(6.0*d + 1e-10) + q.z), d/(q.x + 1e-10), q.x);
}

// возвращаю в ргб
vec3 hsv2rgb(vec3 c) {
	vec3 p = abs(fract(c.xxx + vec3(0.0, 1.0/3.0, 2.0/3.0))*6.0 - 3.0);
	return c.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}

// тот самый вихрь из первого варианта
vec2 get_swirl_uv(vec2 uv, float strength) {
	vec2 center = vec2(0.5);
	vec2 diff = uv - center;
	float dist = length(diff);
	float angle = atan(diff.y, diff.x) + strength * (0.5 - dist) * sin(TIME * 0.5);
	return center + vec2(cos(angle), sin(angle)) * dist;
}

void fragment() {
	vec2 uv = UV;
	float t = TIME * time_factor;
	
	// тянучка значение шума
	float noise_val = texture(noise_tex, uv * noise_scale + t * 0.05).r;
	
	// искажение сетки волнами
	uv.y += sin(uv.x * 10.0 + t) * wave_strength * noise_val;
	uv.x += cos(uv.y * 10.0 + t * 0.5) * wave_strength * noise_val;
	
	// рябь как круги на воде
	float dist_center = distance(uv, vec2(0.5));
	uv += sin(dist_center * 20.0 - t * ripple_speed) * (wave_strength * 0.5 * noise_val);
	
	// закручивание спиралью
	uv = get_swirl_uv(uv, swirl_strength);
	
	// основной цвет по искаженным координатам
	vec4 tex = texture(TEXTURE, uv);
	
	// кручения цвета по кругу
	vec3 hsv = rgb2hsv(tex.rgb * base_color.rgb);
	hsv.x = fract(hsv.x + t * 0.1 * hue_shift_speed); 
	hsv.y = clamp(hsv.y + 0.2 * noise_val, 0.0, 1.0);
	
	vec3 final_rgb = hsv2rgb(hsv);
	
	// светящийся контур
	float edge_mask = smoothstep(0.35, 0.5, dist_center);
	final_rgb += edge_mask * edge_pulse * edge_color.rgb;
	
	// общее свечение и пульсация всей мембраны
	float pulse = 0.8 + 0.2 * sin(t);
	final_rgb *= (glow_intensity * pulse);
	
	// чутка рандома
	final_rgb += 0.03 * vec3(sin(t * 3.0), cos(t * 2.0), noise_val * 0.1);
	
	COLOR = vec4(final_rgb, tex.a);
}