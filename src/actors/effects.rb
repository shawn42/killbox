define_actor :slice_effect do
  has_behaviors do
    relatively_positioned
    layered ZOrder::Projectile
    short_lived ttl: 500
    graphical
  end

end
