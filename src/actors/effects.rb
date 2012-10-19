define_actor :slice_effect do
  has_behaviors do
    positioned
    layered ZOrder::Projectile
    ttl ttl: 500
    graphical
  end

end
