__private float4 map_rgba(float var, float offset, float factor) {
  float r = 0.0f;
  float g = 0.0f;
  float b = 0.0f;
  float a = var;

  r = (var+offset)*factor*255.0f;
  if (r<0.0f) b = - r;

  if (r > 255.0f) r = 255.0f;
  if (g > 255.0f) g = 255.0f;
  if (b > 255.0f) b = 255.0f;
  if (r < 0.0f) r = 0.0f;
  if (g < 0.0f) g = 0.0f;
  if (b < 0.0f) b = 0.0f;
  float4 rgba = (float4)(r, g, b, a);
  return rgba;
}

__kernel void ke_theta_e_kernel_main(__private parameters par,
                                         __private uint ref,
                                         __private uint dim,
                                         __read_only image3d_t b_source_scalars_0,
                                         __read_only image3d_t b_source_scalars_1,
                                         __read_only image3d_t b_source_scalars_2,
                                         __read_only image3d_t b_source_momenta,
                                         __write_only image3d_t b_target)
{
  position pos = get_pos_bc(par, get_global_id(0), get_global_id(1), get_global_id(2));

  float8 c     = (float8)(0.0f);
  float4 c_ice = (float4)(0.0f);
  state st;

  float theta_e, pd, q_t, q_v;

  // YZ
  if      (dim == 0) {
    c     = read_f8(pos.x+ref, pos.y, pos.z, b_source_scalars_0, b_source_scalars_1);
    c_ice = read_f4(pos.x+ref, pos.y, pos.z, b_source_scalars_2);
    st = init_state_with_ice(par, c, c_ice);
    pd = st.rho_d*par.rd*st.T;
    q_t = (st.rho_l+st.rho_v)/st.rho;
    q_v = (st.rho_v)/st.rho;
    theta_e = st.T*pow(pd/par.pr,-par.rd/(par.cpd+par.cpl*q_t))*exp(par.lre0*q_v/(par.cpd+par.cpl*q_t));
  }
  // XZ
  else if (dim == 1) {
    c     = read_f8(pos.x, pos.y+ref, pos.z, b_source_scalars_0, b_source_scalars_1);
    c_ice = read_f4(pos.x, pos.y+ref, pos.z, b_source_scalars_2);
    st = init_state_with_ice(par, c, c_ice);
    pd = st.rho_d*par.rd*st.T;
    q_t = (st.rho_l+st.rho_v)/st.rho;
    q_v = (st.rho_v)/st.rho;
    theta_e = st.T*pow(pd/par.pr,-par.rd/(par.cpd+par.cpl*q_t))*exp(par.lre0*q_v/(par.cpd+par.cpl*q_t));
  }

  float4 rgba;
  rgba = map_rgba(0.0f, -320.0f, theta_e);
  write_f4(pos.x, pos.y, pos.z, rgba, b_target);
}
