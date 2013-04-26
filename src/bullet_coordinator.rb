class BulletCoordinator

  attr_accessor :active_bullets, :shot_listeners
  def initialize
    @active_bullets = []
    @shot_listeners = Hash.new { 0 }
  end

  def register_bullet(bullet)
    @active_bullets << bullet
    bullet.when :remove_me do
      unregister_bullet bullet
    end

    bullet.when :bullet_moved do
      @shot_listeners.keys.each do |target|
        # current = bullet.position
        # future = current + bullet.vel
        if (bullet.armed? || (bullet.player != target)) && bullet_hits_target?(bullet, target)
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

  def bullet_hits_target?(bullet, target)
    current = bullet.position
    future = current + bullet.vel

    crossed_lines = (target.collision_points + [target.collision_points.first]).each_cons(2).any? do |a, b|
      lines_intersect? current.x, current.y, future.x, future.y, a.x, a.y, b.x, b.y
    end

    crossed_lines || lines_in_polygon?
  end

  def lines_in_polygon?
    false
  end

  def lines_intersect?(x1, y1, x2, y2, x3, y3, x4, y4)
    d1 = compute_direction(x3, y3, x4, y4, x1, y1)
    d2 = compute_direction(x3, y3, x4, y4, x2, y2)
    d3 = compute_direction(x1, y1, x2, y2, x3, y3)
    d4 = compute_direction(x1, y1, x2, y2, x4, y4)
    (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
       ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) ||
       (d1 == 0 && on_segment?(x3, y3, x4, y4, x1, y1)) ||
       (d2 == 0 && on_segment?(x3, y3, x4, y4, x2, y2)) ||
       (d3 == 0 && on_segment?(x1, y1, x2, y2, x3, y3)) ||
       (d4 == 0 && on_segment?(x1, y1, x2, y2, x4, y4))
  end

  def compute_direction(xi, yi, xj, yj, xk, yk)
    a = (xk - xi) * (yj - yi)
    b = (xj - xi) * (yk - yi)
    a < b ? -1 : a > b ? 1 : 0
  end

  def on_segment?(xi, yi, xj, yj, xk, yk)
    (xi <= xk || xj <= xk) && (xk <= xi || xk <= xj) &&
     (yi <= yk || yj <= yk) && (yk <= yi || yk <= yj)
  end

end
