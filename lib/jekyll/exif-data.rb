module Jekyll
  module ExifData
    require 'exifr'
    require 'exifr/jpeg'
    require 'xmp'
    module ExifDataFilter

      # Read exif using exifr
      def exif(input, exiftag)
        exif = EXIFR::JPEG::new(input)
        xmp = XMP.parse(exif)

        if xmp
          xmp_data = {}
          xmp.namespaces.each do |namespace_name|
            namespace = xmp.send(namespace_name)
            namespace.attributes.each do |attr|
#              puts "#{namespace_name}.#{attr}: " + namespace.send(attr).inspect
              xmp_data["#{attr}"] = namespace.send(attr).inspect
            end
          end
          if xmp_data[exiftag]
            return xmp_data[exiftag].delete_prefix('"').delete_suffix('"').delete_prefix('["').delete_suffix('"]')
          end 
        end

        if(exiftag == "gps?")
          return (exif.send('gps') != nil)
        end
        answer = exiftag.split('.').inject(exif) do |exif,tag|
             exif.send(tag)
        end

        if(answer == nil)
          return ""
        else
          return answer
        end
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::ExifData::ExifDataFilter)