define_behavior :labeled do
  requires :stage

  setup do
    actor.has_attributes label_text: "", label: nil
    label_attributes = actor.attributes.dup
    label_attributes.delete :view
    actor.label = stage.create_actor :label, label_attributes
    actor.when :label_text_changed do |old_label, new_label|
      actor.label.text = new_label
    end
    actor.label.text = actor.label_text
  end

  remove do
    actor.label.remove
  end
end
