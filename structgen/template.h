#pragma once
#include <vector>
#include <cstring>
#include <string>
#include <glm/glm.hpp>

{% for struct in structs %}
struct {{ struct.name }} {
    {% for field in struct.fields %}
    {{ field.type }} {{ field.name }};
    {% endfor %}

    std::vector<unsigned char> serialize() const {
        std::vector<unsigned char> data;
        size_t total_size = 0;
        {% for field in struct.fields %}
        {% if field.type == 'string' %}
        total_size += sizeof(uint32_t) + {{ field.name }}.length();
        {% elif field.type == 'vec3' %}
        total_size += sizeof(glm::vec3);
        {% elif field.type == 'vec4' %}
        total_size += sizeof(glm::vec4);
        {% elif field.type == 'mat3' %}
        total_size += sizeof(glm::mat3);
        {% elif field.type == 'mat4' %}
        total_size += sizeof(glm::mat4);
        {% else %}
        total_size += sizeof({{ field.type }});
        {% endif %}
        {% endfor %}
        data.reserve(total_size);
        {% for field in struct.fields %}
        {% if field.type == 'string' %}
        uint32_t str_len = static_cast<uint32_t>({{ field.name }}.length());
        data.insert(data.end(), 
                    reinterpret_cast<const unsigned char*>(&str_len),
                    reinterpret_cast<const unsigned char*>(&str_len) + sizeof(uint32_t));
        data.insert(data.end(), 
                    reinterpret_cast<const unsigned char*>({{ field.name }}.data()),
                    reinterpret_cast<const unsigned char*>({{ field.name }}.data()) + {{ field.name }}.length());
        {% elif field.type == 'vec3' %}
        data.insert(data.end(),
                    reinterpret_cast<const unsigned char*>(&{{ field.name }}),
                    reinterpret_cast<const unsigned char*>(&{{ field.name }}) + sizeof(glm::vec3));
        {% elif field.type == 'vec4' %}
        data.insert(data.end(),
                    reinterpret_cast<const unsigned char*>(&{{ field.name }}),
                    reinterpret_cast<const unsigned char*>(&{{ field.name }}) + sizeof(glm::vec4));
        {% elif field.type == 'mat3' %}
        data.insert(data.end(),
                    reinterpret_cast<const unsigned char*>(&{{ field.name }}),
                    reinterpret_cast<const unsigned char*>(&{{ field.name }}) + sizeof(glm::mat3));
        {% elif field.type == 'mat4' %}
        data.insert(data.end(),
                    reinterpret_cast<const unsigned char*>(&{{ field.name }}),
                    reinterpret_cast<const unsigned char*>(&{{ field.name }}) + sizeof(glm::mat4));
        {% else %}
        data.insert(data.end(),
                    reinterpret_cast<const unsigned char*>(&{{ field.name }}),
                    reinterpret_cast<const unsigned char*>(&{{ field.name }}) + sizeof({{ field.type }}));
        {% endif %}
        {% endfor %}
        
        return data;
    }

    static {{ struct.name }} deserialize(const std::vector<unsigned char>& data) noexcept {
        {{ struct.name }} obj{};
        size_t offset = 0;
        
        {% for field in struct.fields %}
        {% if field.type == 'string' %}
        if (offset + sizeof(uint32_t) <= data.size()) {
            uint32_t str_len = 0;
            std::memcpy(&str_len, data.data() + offset, sizeof(uint32_t));
            offset += sizeof(uint32_t);
            
            if (offset + str_len <= data.size()) {
                obj.{{ field.name }}.assign(
                    reinterpret_cast<const char*>(data.data() + offset),
                    str_len
                );
                offset += str_len;
            }
        }
        {% elif field.type == 'vec3' %}
        if (offset + sizeof(glm::vec3) <= data.size()) {
            std::memcpy(&obj.{{ field.name }}, data.data() + offset, sizeof(glm::vec3));
            offset += sizeof(glm::vec3);
        }
        {% elif field.type == 'vec4' %}
        if (offset + sizeof(glm::vec4) <= data.size()) {
            std::memcpy(&obj.{{ field.name }}, data.data() + offset, sizeof(glm::vec4));
            offset += sizeof(glm::vec4);
        }
        {% elif field.type == 'mat3' %}
        if (offset + sizeof(glm::mat3) <= data.size()) {
            std::memcpy(&obj.{{ field.name }}, data.data() + offset, sizeof(glm::mat3));
            offset += sizeof(glm::mat3);
        }
        {% elif field.type == 'mat4' %}
        if (offset + sizeof(glm::mat4) <= data.size()) {
            std::memcpy(&obj.{{ field.name }}, data.data() + offset, sizeof(glm::mat4));
            offset += sizeof(glm::mat4);
        }
        {% else %}
        if (offset + sizeof({{ field.type }}) <= data.size()) {
            std::memcpy(&obj.{{ field.name }}, data.data() + offset, sizeof({{ field.type }}));
            offset += sizeof({{ field.type }});
        }
        {% endif %}
        {% endfor %}
        return obj;
    }
};
{% endfor %}