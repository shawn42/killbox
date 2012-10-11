class BulletCoordinator

  def initialize
    @active_bullets = []
    @shot_listeners = Hash.new { 0 }
  end

  def register_bullet(bullet)
    @active_bullets << bullet
    bullet.when :bullet_moved do
      unregister_bullet bullet
      x, y = bullet.x, bullet.y
      @shot_listeners.keys.each do |target|
        # TODO how to do this better
        distance = (vec2(target.x, target.y) - vec2(bullet.x, bullet.y)).magnitude
        if distance < 20
        # if target.bb.collide_point?(bullet.x, bullet.y)
          log "GOT EM"
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
