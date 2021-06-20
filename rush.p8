pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- globals and structs
local dg = 0.071
local ent_count = 0

local entities = {
	name, 
	x, 
	y, 
	dx, 
	dy, 
	gmod,
	sprite,
	size,
	draw,
	move,
	die,
	debug
}

local bullets = {
	x, 
	y, 
	dx, 
	dy, 
	name, 
	gmod,
	sprite,
	size,
	draw,
	move,
	die,
	debug
}

local anim = {
	name,
	sprite,
	size_mod,
	length,
	frame_diff
}

-- animations
--an.a = define_anim("char", 1, 0, 1, 1)
--an.b = define_anim("bubble", 1, 0, 3, 1)

function _init()
	-- comment
	
	cls()
	-- set random seed
	srand(420)
	
	-- some entities
	new_entity(10, 10, 1, slide)
	new_entity(50, 50, 1, slide)
	new_entity(20, 20, 10, controller1, "player1", 19)
	new_bullet(70, 70)
	
end




-->8
--velocity functions

function combo(self, v, a, b)
	b(self, a(self, v))
end

--- prefab functions
function test_go(self)
 wave(self)
 dt(self)
 friction(self)
end

function staticy(self)
	combo(self, rnd(1), wave, abs_wave)
	no_clip(self)
end

function staticy2(self)
	t = rnd(1)
	combo(self, t, wave, abs_wave)
	no_clip(self)
end

function swirly_go(self)
	combo(self, 0, wave, abs_wave)
	no_clip(self)
end

--- movement functions
function wave(self, v)
	v = v or 0
	self.dx += sin(time() + v)
	self.dy += cos(time() + v)
	
	return(v)
end

function abs_wave(self, v)
 v = v or 0
	self.dx += abs(sin(time() + v))
	self.dy += abs(cos(time() + v))
	
	return(v)
end

--- physics functions
function dt(self)
	self.x += self.dx
	self.y += self.dy
end

function friction(self)
	self.dx = 0
	self.dy = 0
end

function go(self)
	if (not_collide(
		self.x+self.dx, self.y+self.dy)
	) then
		dt(self)
	end
	
 friction(self)
end

function slide(self)
	dt(self)
end

function no_clip(self)
	dt(self)
	friction(self)
end


-->8
--player code


--- collision functions
function is_tile(tile_type, _x, _y)
	x = flr(_x)
	y = flr(_y)
	tile=mget(x,y)
	has_flag=fget(tile, tile_type)
	return has_flag
end

function not_collide(x, y)
	return not is_tile(wall, x, y)
end


--- controller functions
function controller1(self)
	if(btnp(⬅️)) self.dx-=4
	if(btnp(➡️)) self.dx+=4
	if(btnp(⬆️)) self.dy-=4
	if(btnp(⬇️)) self.dy+=4
	
	go(self)
end


--- generic functions
function kill(self)
	del(entities, self.name)
end

function remove(self)
	del(bullets, self.name)
end

function do_draw(self)
	-- size = height*4 + width - 1
	-- therefore, 4x4 = 19; 1x1 = 4; 0.5x2 = 7.5
 _w = self.size % 4 + 1
 _h = self.size \ 4
 
 spr(self.sprite, self.x+8*_w, self.y+8*_h, _w, _h)
end


--- constructor
function new_entity(_x, _y, _spr, _ctrl, _name, _size)
	ent_count += 1
	val = {
  name = _name or ent_count,
  x=_x,
  y=_y,
  dx=1,
  dy=0,
  gmod=2,
  sprite= _spr or 1,
  size = _size or 4,
  draw=do_draw,
  move = _ctrl or go,
		die = kill,
		debug = function(self)
			line(0, 0, self.x, 100, 10)
			line(0, 0, self.dx, 105, 11)
		end
	}
	
 add(entities, val)
 return(val)
end


function new_bullet(_x, _y, _spr, _ctrl, _name, _size)
	val = new_entity(_x, _y, _spr, _ctrl, _name, _size)
 val.gmod = 0
 val.sprite = _spr or 16
 val.move = _ctrl or test_go
	--	die=remove,
	val.debug = function(self)
		line(0, 0, self.x, self.y, 5)
		line(0, 0, self.dx, self.dy, 6)
	end
	
	add(bullets, val)
	--del(entities, val)
	return(val)
end

--- draw sprites
function draw_small_boy(val, x, y)
	spr(val, x, y)
end

function draw_big_boy(val, x, y, h, w)
 for i = 0,3,1 do
 	for j = 0,3,1 do
 		spr(val+i+j*16, x+8*i, y+8*j)
 	end
 end
end
-->8
--map code

function map_setup()
 -- map tile settings
 wall = 0
 key = 1
 door = 2
 warp = 3
 kill = 4
 lose = 5
 win = 6
end

function draw_map()
	map(0, 0, 0, 0, 128, 64)
end
-->8
-- update call

function test_debug(table)
 for e in all(table) do
  e:debug()
 end
end

function gravity(table)
	for e in all(table) do
		e.dy += dg*e.gmod
	end
end

function go_everyone(table)
	for e in all(table) do
	 e:move()
	end
end

function _update()
	gravity(entities)
	
	go_everyone(entities)
	go_everyone(bullets)
	--test_debug(bullets)
	
	if(btnp(⬇️)) new_bullet(30, 30, 32, swirly_go)
end
-->8
-- draw call
function draw_debug()
	for e in all(entities) do
		e:debug()
	end
end

function define_anim(_spr, _sm, _l, _fd)
 add(anim, {
		sprite=_spr,
		size_mod=_sm,
		length=_l,
		frame_diff=_fd
	})
end


function _draw()
	cls()
	draw_map()
	draw_small_boy(1, 38, 23)
	draw_big_boy(10, 60, 20)
	
	for e in all(entities) do
		e:draw()
	end
	
	for e in all(bullets) do
	 e:draw()
	end
	
	--draw_debug()
end

function test()
	-- x, y offset from topleft
	-- x2, y2 offset from topleft
	-- color
	rect(10, 10, 20, 20, 8)
	box(30, 30, 10, 10, 5)
end

function box(x, y, w, h, c)
	-- rect with offset instead
 rect(x, y, x + w, y + h, c)
 
 -- circ() does circles
 -- pset does points
 -- rectfill
 -- circfill
 -- line
end


__gfx__
00000000000000000000000011111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000080808000000000011111111111111111d11111100000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000898889000000000111111111ddddd1111d111d100000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000829999900000000011111111111111111111111100000000000000000000000000000000000000000088800000000000000000000000000000000000
0007700002282800000000001111111111111111111d111100000000000000000000000000000000000000880080080000000000000000000000000000000000
007007000222220000000000111111111111dd11111111d100000000000000000000000000000000000000888800008000000000880000000000000000000000
000000000220000000000000111111111d111111d111d11100000000000000000000000000000000000000888007000888888888800000000000000000000000
000000000e0e00000000000011111111111111111111111100000000000000000000000000000000000008000000700000800888000000000000000000000000
00cccc00000cc0000000c00022222222222666222222222200000000000000000000000000000000000008000000700000888000000000000000000000000000
0c1177c00c1070c00c0000c026662226666622222226662200000000000000000000000000000000000008800000000000880000000000000000000000000000
c100171cc100107c0000000022266622222222222666222200000000000000000000000000000000000000800000000000088800000000000000000000000000
c000017c0000001cc000000022222222222226662222222200000000000000000000000000000000000000080000000000008888800000000000000000000000
c000011cc00001000000000c26622666266622222222266600000000000000000000000000000000000000080000000088880000000000000000000000000000
c100011cc010010c00000000222662222622226622222222000000000000000000000000000000000000000800eeeee880000000000000000000000000000000
0c1111c00c0100c00c0000c062222266222662222266622200000000000000000000000000000000000000008ee0eeeeee000000000000000000000000000000
00cccc00000cc000000c000026222662222222222222226200000000000000000000000000000000000000008eeeeeeeee000000000000000000000000000000
0000009000000000000000001111111111111111111111110000000000000000000000000000000000ddddde8eeeeeeeeeeeedddd00000000000000000000000
9009090000000000000000001c1111c1111111c1111111110000000000000000000000000000000000d000ddeeeeeeeeeeee2e00d00000000000000000000000
0900090000000000000000001cc11cc1111111c1111441110000000000000000000000000000000000d00ddeeeeeeee0ee22eed0d00000000000000000000000
0090000000000000000000001cc1ccc11c1111c1111c4111000000000000000000000000000000000ddddd0eeee22222222eeeddd00000000000000000000000
00000900000000000000000011cccc111c11111111c11111000000000000000000000000000000000ddd00eeeeeeeeeeeeeeee0ddd0000000000000000000000
009000900000000000000000111cc1111c11c11111c111110000000000000000000000000000000000d000ee0eeeeee0eee22e00dd0000000000000000000000
009090090000000000000000111111111111c11111c1111100000000000000000000000000000000000000ee022222222220e000000000000000000000000000
090000000000000000000000111111111111111111111111000000000000000000000000000000000000000e00e0eeeeeeeee000000000000000000000000000
00cccc0000cccc0000cccc0000101c000000000000000000000000000000000000000000000000000000000ee00eeeeeeeedd000000000000000000000000000
0c1177c00c1177c00c1117c00c7001c000000000000000000000000000000000000000000000000000000000ee00000ee0e0dd00000000000000000000000000
c100171cc100171c0100c11c000000000000000000000000000000000000000000000000000000000000000d0deeeee0eed00d00000000000000000000000000
c000017cc000017c00c0017c1000107c0000000000000000000000000000000000000000000000000000000d0d0000ee00d00d00000000000000000000000000
c000011c1710011c0000c11c001000100000000000000000000000000000000000000000000000000000000dd0000000000d0d00000000000000000000000000
c100011c0101011c010000c0000010000000000000000000000000000000000000000000000000000000000dd00000000000d000000000000000000000000000
0c1111c0000c11c00000100070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cccc0000001c000010000000c01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888228228888228822888222822888888822888888ff8888
88888f8f8f8f88828282828888888888888888888888888888888888888888888888888888888888882288822888222222888222822888882282888888fff888
88888f8f8f8f88888888888888888888888888888888888888888888888888888888888888888888882288822888282282888222888888228882888888f88888
88888f8f8f8f888282828288888888888888888888888888888888888888888888888888888888888822888228882222228888882228882288828888fff88888
88888f8f8f8f88888888888888888888888888888888888888888888888888888888888888888888882288822888822228888228222888882282888ffff88888
88888f8f8f8f88828282828888888888888888888888888888888888888888888888888888888888888228228888828828888228222888888822888fff888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555a5050505555b5c5050555505050505555050505055550505050555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555556666666665577777777755666666666556666666665566666666655555555555555555555555555555555555
555566656665666566656665666566555555e55565556555655755575577556555655565565556555655655565656555e5555555551555555555555555555555
55556565656556555655655565656565555ee55565656565655757577577556565666565565656665655656565656555ee555555551155555155155511115555
5555666566655655565566556655656555eee55565656565655757577577556565655565565656655655656565556555eee55551111115551155155511115555
55556555656556555655655565656565555ee55565656565655757577577556565656665565656665655656566656555ee555551001105511111155511115555
555565556565565556556665656565655555e55565556555655755575557556555655565565556555655655566656555e5555551551055501100055511115555
55555555555555555555555555555555555555556666666665577777777755666666666556666666665566666666655555555550550555550155555500005555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555055555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555500000000055555555555555555555550000000005555555555555555555555555555555555555555555555555555555555555555555555555555
555556666655066606660555555d555555556666655066606060555555d555555556666655555555555555555555555555666665555555555555555555555555
55555655565506060006055555d5d5555555655565506060606055555d5d55555556555655555555555555555555555555655565555555555555555555555555
5555565756550606006605555d5d5555555565756550606066605555d5d555555556555655555555555555555555555555655565555555555555555555555555
555556555655060600060555d5d5555555556555655060600060555d5d5555555556555655555555555555555555555555655565555555555555555555555555
555556666655066606660555dd55555555556666655066600060555dd55555555556666655555555555555555555555555666665555555555555555555555555
55555555555500000000055555555555555555555550000000005555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507770000066600eee00ccc00000005500770000066000e0e00cc000ddd0055055555555555555555555555555505505555555555555555555555555550555
55507000000000600e0000c0000000005507000000006000e0e000c000d000055055555555555555555555555555505505555555555555555555555555550555
55507700000066600eee00ccc00000005507000000006000eee000c000ddd0055055555555555555555555555555505505555555555555555555555555550555
5550700000006000000e0000c0000000550707000000600000e000c00000d0055055555555555555555555555555505505555555555555555555555555550555
55507770000066600eee00ccc000d000550777000006660000e00ccc00ddd0055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507770000066600eee00ccc0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507000000000600e0000c000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507700000066600eee00ccc0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
5550700000006000000e0000c0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507000000066600eee00ccc000d000550010001000100001000010000100055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500770000066600eee00c0c0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507000000000600e0000c0c0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507000000066600eee00ccc0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
5550707000006000000e0000c0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507770000066600eee0000c000d000550010001000100001000010000100055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507770000066600eee00c0c0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507070000000600e0000c0c0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507770000066600eee00ccc0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
5550707000006000000e0000c0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507070000066600eee0000c000d000550010001000100001000010000100055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507770000066600eee00c0c0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507070000000600e0000c0c0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507700000066600eee00ccc0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
5550707000006000000e0000c0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507770000066600eee0000c000d000550010001000100001000010000100055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500770000066600eee00ccc0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507000000000600e000000c0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507000000006600eee000cc0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
5550700000000060000e0000c0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500770000066600eee00ccc000d000550010001000100001000010000100055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507700000066600eee00ccc0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507070000000600e000000c0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507070000006600eee000cc0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
5550707000000060000e0000c0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507770000066600eee00ccc000d000550010001000100001000010000100055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507770000066600eee00ccc0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507000000000600e0000c000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507700000006600eee00ccc0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
5550700000000060000e0000c0000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507770000066600eee00ccc000d000550010001000100001000010000100055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55505050505050505050505050505050550505050505050505050505050505055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507770000066600eee00ccc00dd000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507000000000600e0000c00000d000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507700000006600eee00ccc000d000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
5550700000000060000e0000c000d000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507770000066600eee00ccc00ddd00550010001000100001000010000100055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507770000066600eee00ccc00dd000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507000000000600e0000c00000d000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507700000006600eee00ccc000d000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
5550700000000060000e0000c000d000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507770000066600eee00ccc00ddd00550010001000100001000010000100055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507770000066600eee00ccc00dd000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507000000000600e0000c00000d000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507700000006600eee00ccc000d000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
5550700000000060000e0000c000d000550000000000000000000000000000055055555555555555555555555555505505555555555555555555555555550555
55507770000066600eee00ccc00ddd00550010001000100001000010000100055055555555555555555555555555505505555555555555555555555555550555
55500000000000000000000000000000550000000000000000000000000000055000000000000000000000000000005500000000000000000000000000000555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888
88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888

__gff__
0000000000000000000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0303030503030303030303030303131303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303040305030303030325151414030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303040303032303040303030324131403030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0323030303030303030325032524151403030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030503040303030303032424140324030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303032403030305240403032425152325030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303040503230303030303230313152423030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303240313150325030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0304030303050303042503052514152523030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2403050304030304030324032514152303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303230305032303240305032515132324030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1403030324030303030313151515032325030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1415131315131314151414030324232303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515141414151514030325030325030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303252324250324252503030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0324242424242303242403030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010400000c21000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001905000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010400001f5221f5221f5221f5221f5221f5221f5221f5221f5221f5221f5221f5221f5221f5221f5221f5221f5221f5221f5221f5221f5121f5121f5121f5121f5121f5151f5151f5151f515000000000000000
010800001c5501d5501f5402154023540245302653028550285512855128551285512855128551285512855128551285512855128551285512855128551000000000023552235522355223552245522455224552
011100001371213712137121371213712137121371213712137121371213712137121371213712137121371213712137121371213712137121371213712137121371213712137121371213712137121371213712
010e00001805118051180511805118051180511805118051180511805118051180511805118051180511805118051180511805118051180511805118051180511805118051180511805118051180511805118051
003700001353013520135101351013510135101351013515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 02414340
00 03064344
00 05424344

