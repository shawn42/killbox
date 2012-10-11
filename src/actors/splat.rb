define_actor :splat do

  has_behaviors do
    positioned
    layered ZOrder::Projectile
    # animated_with_spritemap file: 'bomb.png', rows: 1, cols: 2, actions: {idle: 0..1}
    animated once: true
  end
end
