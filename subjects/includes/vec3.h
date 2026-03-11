#ifndef VEC3_H
# define VEC3_H

typedef struct s_vec3
{
	double	x;
	double	y;
	double	z;
}	t_vec3;

/* Constructeur */
t_vec3	vec3(double x, double y, double z);

/* Operations */
t_vec3	vec_add(t_vec3 a, t_vec3 b);
t_vec3	vec_sub(t_vec3 a, t_vec3 b);
t_vec3	vec_scale(t_vec3 v, double t);

/* Produits */
double	vec_dot(t_vec3 a, t_vec3 b);
t_vec3	vec_cross(t_vec3 a, t_vec3 b);

/* Utilitaires */
double	vec_length(t_vec3 v);
t_vec3	vec_normalize(t_vec3 v);

#endif
