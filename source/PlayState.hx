package;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	private var _player:Player;
	private var playerBullets:FlxTypedGroup<Bullet>;
	public var player_start:FlxObject;
	
	private var _enemy:Enemy;
	
	private var _map:TiledLevel;
	private var _mWalls:FlxTilemap;
	
	private var _grpPeople:FlxTypedGroup<FlxSprite>;
	private var _grpEnemies:FlxTypedGroup<Enemy>;
	private var _grpText:FlxTypedGroup<FlxText>;
	
	private var wasdTxt:FlxText;
	private var _txtShoot:FlxText;
	
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		FlxG.camera.bgColor = FlxColor.BLACK;
		FlxG.camera.fade(FlxColor.GRAY, 5, true);
		
		_grpPeople = new FlxTypedGroup<FlxSprite>();
		add(_grpPeople);
		
		_grpEnemies = new FlxTypedGroup<Enemy>();
		add(_grpEnemies);
		
		_grpText = new FlxTypedGroup<FlxText>();
		add(_grpText);
		
		playerBullets = new FlxTypedGroup<Bullet>();
		add(playerBullets);
		
		
		_player = new Player(0, 0, playerBullets);
		_grpPeople.add(_player);
		
		_map = new TiledLevel(AssetPaths.levelGood__tmx, this);
		add(_map.backgroundLayer);
		add(_map.imagesLayer);
		add(_map.BGObjects);
		add(_map.foregroundObjects);
		add(_map.objectsLayer);
		add(_map.collisionTiles);
		
		FlxG.camera.follow(_player, FlxCameraFollowStyle.PLATFORMER);
		_player.setPosition(player_start.x, player_start.y);
		
		wasdTxt = new FlxText(_player.x - 64, _player.y - 100, 0, "A & D == Move", 16);
		add(wasdTxt);
		
		_txtShoot = new FlxText(170, 720, 0, "Spacebar to shoot", 16);
		add(_txtShoot);
		_txtShoot.visible = false;
		
		_grpPeople.forEach(initPeople);
		_grpEnemies.forEach(initPeople);

		super.create();
	}
	
	private function initPeople(p:FlxSprite):Void
	{
		p.acceleration.y = 600;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (_player.justShot)
		{
			var flash:MuzzleFlash = new MuzzleFlash(_player.xPos, _player.y + 26);
			add(flash);
			
			FlxG.camera.shake(0.01, 0.1);
		}
		
		playerBullets.forEachAlive(collisionCheck);
		
		FlxG.collide(_grpPeople, _map.foregroundTiles);
		FlxG.collide(_grpEnemies, _map.foregroundTiles);
		
		_grpEnemies.forEachAlive(followCheck);
		
	}
	
	
	private function followCheck(e:Enemy):Void
	{
		e.acceleration.x = 0;
		if (!e.finalSection)
		{
			if (e.y > _player.y && e.velocity.y == 0 && e.color == FlxColor.WHITE)
			{
				e.velocity.y -= 360;
			}
			
			if (e.color == FlxColor.WHITE)
			{
				
				if (FlxMath.distanceBetween(e, _player) >= e.rndDistance)
				{
					var accel:Float = e.rndAccel;
					if (e.x > _player.x)
					{
						e.acceleration.x = -accel;
					}
					else
					{
						e.acceleration.x = accel;
					}
				}
			}
		}
		
	}
	
	private function collisionCheck(b:Bullet):Void
	{
		for (e in _grpEnemies.members)
		{
			if (FlxG.overlap(b, e) && e.color != FlxColor.WHITE)
			{
				e.hit();
				e.x += b.velocity.x * FlxG.random.float(0.001, 0.01);
				muzzFlash(b);
			}
		}
		
		if (FlxG.collide(b, _map.foregroundTiles))
		{
			muzzFlash(b);
		}
		
	}
	
	private function muzzFlash(b:Bullet):Void
	{
		var flash:MuzzleFlash = new MuzzleFlash(b.x, b.y);
		add(flash);
		
		b.kill();
	}
	
	private function changeColor(t:FlxText):Void
	{
		t.color = FlxColor.BLACK;
	}
	
}