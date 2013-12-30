# == Defined Type
#
# Parses the full path to the image, stores the image to
# the ckan_img_dir
#
define ckan::custom_images {
  $img_name_array = split($name,'/')
  $img_name = $img_name_array[-1]
  file {"$ckan::config::ckan_img_dir/$img_name":
    ensure => file,
    source => $name,
  }
}
