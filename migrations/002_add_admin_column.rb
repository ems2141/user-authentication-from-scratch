Sequel.migration do
  up do
    add_column :users, :administrator, FalseClass, default: false
  end

  down do
    drop_column :users, :administrator
  end
end