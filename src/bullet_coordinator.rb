class BulletCoordinator

  attr_accessor :active_bullets, :shot_listeners
  def initialize
    @active_bullets = []
    @shot_listeners = Hash.new { 0 }
  end

  def register_bullet(bullet)
    @active_bullets << bullet
    bullet.when :bullet_moved do
      unregister_bullet bullet
      @shot_listeners.keys.each do |target|
        current = vec2(bullet.x, bullet.y)
        future = current + bullet.vel
        if LineClipper.clip(current.x, current.y, future.x, future.y, target.bb)
        # if target.bb.collide_point?(bullet.x, bullet.y)
          target.react_to :shot, bullet
        end
      end
    end
  end

  def register_shootable(shootable)
    @shot_listeners[shootable] += 1
  end

  def unregister_shootable(shootable)
    @shot_listeners[shootable] -= 1
    @shot_listeners.delete shootable if @shot_listeners[shootable] == 0
  end

  def unregister_bullet(bullet)
    @active_bullets.delete bullet
  end

end
