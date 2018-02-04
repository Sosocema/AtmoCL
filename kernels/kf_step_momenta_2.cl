__kernel void kf_step_momenta_2_kernel_main(__private parameters par,
                                            __read_only image3d_t bf_momenta_fc_a,
                                            __read_only image3d_t bRhs_p_fc,
                                            __read_only image3d_t bsRhs_momenta_fc_0,
                                            __read_only image3d_t bsRhs_momenta_fc_1,
                                            __read_only image3d_t bsRhs_momenta_fc_2,
                                            __read_only image3d_t bs_momenta_fc_0,
                                            __read_only image3d_t bs_momenta_fc_1,
                                            __read_only image3d_t bs_momenta_fc_2,
                                            __write_only image3d_t bf_momenta_fc_b)
{
  position pos = get_pos_bc(&par);

  int s = 2;
  float di = par.b[s][0] + par.b[s][1] + par.b[s][2];
  float4 z0, z1, prs, fyn[3], y_m[3];

  z0     = read_imagef(bf_momenta_fc_a,    (int4)(pos.x, pos.y, pos.z, 0));
  prs    = read_imagef(bRhs_p_fc,          (int4)(pos.x, pos.y, pos.z, 0));
  fyn[0] = read_imagef(bsRhs_momenta_fc_0, (int4)(pos.x, pos.y, pos.z, 0));
  fyn[1] = read_imagef(bsRhs_momenta_fc_1, (int4)(pos.x, pos.y, pos.z, 0));
  fyn[2] = read_imagef(bsRhs_momenta_fc_2, (int4)(pos.x, pos.y, pos.z, 0));
  y_m[0] = read_imagef(bs_momenta_fc_0,    (int4)(pos.x, pos.y, pos.z, 0));
  y_m[1] = read_imagef(bs_momenta_fc_1,    (int4)(pos.x, pos.y, pos.z, 0));
  y_m[2] = read_imagef(bs_momenta_fc_2,    (int4)(pos.x, pos.y, pos.z, 0));

  z1 = z0 + prs*par.dtis[s];
  z1 += par.g[s][1]*(y_m[1]-y_m[0])/par.dT/di*par.dtis[s];
  z1 += par.g[s][2]*(y_m[2]-y_m[0])/par.dT/di*par.dtis[s];

  // dont need to select components because fyn[] only have .y and .z
  z1 += par.b[s][0]*fyn[0]/di*par.dtis[s];
  z1 += par.b[s][1]*fyn[1]/di*par.dtis[s];
  z1 += par.b[s][2]*fyn[2]/di*par.dtis[s];

  write_imagef(bf_momenta_fc_b, (int4)(pos.x, pos.y, pos.z, 0), z1);
}
