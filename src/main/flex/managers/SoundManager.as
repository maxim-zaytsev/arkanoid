package managers {
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.system.ApplicationDomain;

public class SoundManager {

    private var introSoundClass : Class;
    private var levelSoundClass : Class;
    private var pickupClass:Class;
    private var shootClass:Class;
    private var jumpClass:Class;
    private var introMusic : Sound;
    private var channel : SoundChannel;
    private var _pickupSound:Sound;
    private var _shootSound:Sound;
    private var _jumpSound:Sound;

    public function SoundManager(appDomain : ApplicationDomain) {
        introSoundClass = appDomain.getDefinition("IntroSound") as Class;
        levelSoundClass = appDomain.getDefinition("LevelSound") as Class;
        pickupClass = appDomain.getDefinition("Pickup") as Class;
        shootClass = appDomain.getDefinition("Shoot") as Class;
        jumpClass = appDomain.getDefinition("Jump") as Class;

        _pickupSound = new pickupClass() as Sound;
        _shootSound = new shootClass() as Sound;
        _jumpSound = new jumpClass() as Sound;
    }

    public function blockCrash():void{
        _pickupSound.play();
    }

    public function wallHit():void{
        _shootSound.play();
    }

    public function batHit():void{
        _jumpSound.play();
    }

    public function playIntroMusic():void {
        introMusic = new introSoundClass();
        channel = introMusic.play(0, int.MAX_VALUE);
    }

    public function stopPlaying():void {
        channel.stop();
    }

    public function playLevelMusic():void {
        introMusic = new levelSoundClass();
        channel = introMusic.play(0, int.MAX_VALUE);
    }
}
}
