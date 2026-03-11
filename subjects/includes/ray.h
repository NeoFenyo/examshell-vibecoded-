#ifndef RAY_H
# define RAY_H

# include "vec3.h"

typedef struct s_ray
{
	t_vec3	origin;
	t_vec3	direction;
}	t_ray;

t_ray	ray_create(t_vec3 origin, t_vec3 direction);
t_vec3	ray_at(t_ray r, double t);

#endif
