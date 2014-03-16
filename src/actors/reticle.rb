define_actor :reticle do
  
  has_attribute x_scale: 0.5, y_scale: 0.5
  has_behaviors do
    positioned
    layered ZOrder::Projectile
    animated_with_spritemap file: 'trippers/props.png', rows: 4, cols: 6, actions: { idle: 12..17 }
    graphical
  end
end
